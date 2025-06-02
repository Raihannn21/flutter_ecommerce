<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse; // Pastikan ini di-import
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log; // Jika masih perlu debugging, bisa dipertahankan

class ProductController extends Controller
{
    /**
     * Display a listing of the products.
     * Endpoint: GET /api/products
     * Akses: Publik (User & Admin)
     */
    public function index(Request $request): JsonResponse
    {
        // <<<<<<<<<< PERBAIKAN DI SINI UNTUK PAGINATION
        $perPage = $request->query('per_page', 20); // Ambil per_page dari query param, default 20 produk per halaman
        $products = Product::paginate($perPage); // Gunakan paginate()

        // Mengembalikan respons JSON dengan data produk dan metadata pagination
        return response()->json([
            'message' => 'Products retrieved successfully.',
            'data' => $products->items(), // Mengambil hanya item data dari paginator
            'pagination' => [ // Menambahkan metadata pagination
                'total' => $products->total(),
                'per_page' => $products->perPage(),
                'current_page' => $products->currentPage(),
                'last_page' => $products->lastPage(),
                'from' => $products->firstItem(),
                'to' => $products->lastItem(),
            ]
        ], 200);
        // <<<<<<<<<< AKHIR PERBAIKAN
    }

    /**
     * Store a newly created product in storage.
     * Endpoint: POST /api/admin/products
     * Akses: Admin Saja
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
     * Display the specified product.
     * Endpoint: GET /api/products/{id}
     * Akses: Publik (User & Admin)
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
     * Update the specified product in storage.
     * Endpoint: PUT /api/admin/products/{id}
     * Akses: Admin Saja
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
     * Endpoint: DELETE /api/admin/products/{id}
     * Akses: Admin Saja
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