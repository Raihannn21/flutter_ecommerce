<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Subcategory;
use App\Models\ProductType; 
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of the products (standard pagination, no search here).
     * Endpoint: GET /api/products
     * Akses: Publik
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = $request->query('per_page', 20);
        $products = Product::paginate($perPage);

        return response()->json([
            'message' => 'Products retrieved successfully.',
            'data' => $products->items(),
            'pagination' => [
                'total' => $products->total(),
                'per_page' => $products->perPage(),
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
                'from' => $products->firstItem(),
                'to' => $products->lastItem(),
            ]
        ], 200);
    }

    /**
     * Perform a binary search for products by subcategory name.
     * This method demonstrates the binary search algorithm on a sorted collection in PHP.
     * Endpoint: GET /api/products/search-by-subcategory-binary?query={searchQuery}&page={page}&per_page={perPage}
     * Akses: Publik (untuk demonstrasi)
     *
     * WARNING: This approach fetches ALL subcategories and products to memory and sorts them in PHP.
     * It is NOT scalable for large databases. For production, use database's LIKE/ILIKE operators.
     */
    public function binarySearchProductsBySubcategoryName(Request $request): JsonResponse
    {
        $searchQuery = strtolower($request->query('query', ''));
        $page = (int) $request->query('page', 1);
        $perPage = (int) $request->query('per_page', 20);

        Log::info('Binary Search Products by Subcategory: Searching for query "' . $searchQuery . '"');

        $allSubcategories = Subcategory::all(['id', 'name'])->sortBy('name')->values()->toArray();

        $matchingSubcategoryIds = [];
        $subcatSearchSteps = 0;

        if (!empty($searchQuery)) {
            $low = 0;
            $high = count($allSubcategories) - 1;
            $firstMatchIndex = -1;

            while ($low <= $high) {
                $subcatSearchSteps++;
                $mid = floor(($low + $high) / 2);
                $currentSubcatName = strtolower($allSubcategories[$mid]['name']);
                if (str_starts_with($currentSubcatName, $searchQuery)) {
                    $firstMatchIndex = $mid;
                    $high = $mid - 1;
                } elseif ($currentSubcatName < $searchQuery) {
                    $low = $mid + 1;
                } else {
                    $high = $mid - 1;
                }
            }

            if ($firstMatchIndex != -1) {
                for ($i = $firstMatchIndex; $i >= 0; $i--) {
                    if (str_starts_with(strtolower($allSubcategories[$i]['name']), $searchQuery)) {
                        $matchingSubcategoryIds[] = $allSubcategories[$i]['id'];
                    } else {
                        break;
                    }
                }
                for ($i = $firstMatchIndex + 1; $i < count($allSubcategories); $i++) {
                    if (str_starts_with(strtolower($allSubcategories[$i]['name']), $searchQuery)) {
                        $matchingSubcategoryIds[] = $allSubcategories[$i]['id'];
                    } else {
                        break;
                    }
                }
            }
        } else {
            $matchingSubcategoryIds = array_column($allSubcategories, 'id');
        }

        Log::info('Binary Search Products by Subcategory: Found ' . count($matchingSubcategoryIds) . ' matching subcategory IDs.');

        $matchingProductTypeIds = [];
        if (!empty($matchingSubcategoryIds)) {
            $productTypes = ProductType::whereIn('subcategory_id', $matchingSubcategoryIds)->get(['id'])->toArray();
            $matchingProductTypeIds = array_column($productTypes, 'id');
        }
        
        Log::info('Binary Search Products by Subcategory: Found ' . count($matchingProductTypeIds) . ' matching product type IDs.');

        $allProducts = Product::whereIn('product_type_id', $matchingProductTypeIds)
                                ->get(['product_id', 'title', 'image_url', 'gender_id', 'product_type_id', 'colour_id', 'usage_id'])
                                ->toArray();

        usort($allProducts, function ($a, $b) {
            return strcasecmp($a['title'], $b['title']);
        });

        $totalFound = count($allProducts);
        $offset = ($page - 1) * $perPage;
        $paginatedResults = array_slice($allProducts, $offset, $perPage);

        $lastPage = ceil($totalFound / $perPage);
        $from = $offset + 1;
        $to = min($offset + $perPage, $totalFound);

        return response()->json([
            'message' => 'Products searched by subcategory successfully.',
            'data' => $paginatedResults,
            'pagination' => [
                'total' => $totalFound,
                'per_page' => $perPage,
                'current_page' => $page,
                'last_page' => $lastPage,
                'from' => $from,
                'to' => $to,
            ],
            'binary_search_steps_subcategory' => $subcatSearchSteps
        ], 200);
    }

    /**
     * Display the specified product.
     */
    public function show(string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Product not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Product retrieved successfully.',
            'data' => $product
        ], 200);
    }

    /**
     * Store a newly created product in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|integer|unique:products,product_id',
            'gender_id' => 'required|integer|exists:genders,id',
            'product_type_id' => 'required|integer|exists:product_types,id',
            'colour_id' => 'required|integer|exists:colours,id',
            'usage_id' => 'required|integer|exists:usages,id',
            'title' => 'required|string|max:255',
            'image_url' => 'nullable|url|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $product = Product::create($request->all());
        return response()->json([
            'message' => 'Product created successfully.',
            'data' => $product
        ], 201);
    }

    /**
     * Update the specified product in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Product not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'gender_id' => 'sometimes|integer|exists:genders,id',
            'product_type_id' => 'sometimes|integer|exists:product_types,id',
            'colour_id' => 'sometimes|integer|exists:colours,id',
            'usage_id' => 'sometimes|integer|exists:usages,id',
            'title' => 'sometimes|string|max:255',
            'image_url' => 'sometimes|nullable|url|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $product->update($request->all());
        return response()->json([
            'message' => 'Product updated successfully.',
            'data' => $product
        ], 200);
    }

    /**
     * Remove the specified product from storage.
     */
    public function destroy(string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Product not found.'
            ], 404);
        }

        $product->delete();

        return response()->json([
            'message' => 'Product deleted successfully.'
        ], 200);
    }
}
