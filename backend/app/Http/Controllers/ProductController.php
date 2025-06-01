<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse; // Tambahkan ini
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log; // Jika masih perlu debugging, bisa dipertahankan

class ProductController extends Controller
{
    /**
     * Display a listing of the products.
     * Endpoint: GET /api/products
     * Akses: Publik (User & Admin)
     */
    public function index(Request $request): JsonResponse // Ubah return type ke JsonResponse
    {
        $products = Product::all();
        return response()->json([
            'message' => 'Products retrieved successfully.',
            'data' => $products
        ], 200);
    }

    /**
     * Store a newly created product in storage.
     * Endpoint: POST /api/admin/products
     * Akses: Admin Saja
     */
    public function store(Request $request): JsonResponse // Ubah return type ke JsonResponse
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
    public function show(string $id): JsonResponse // Mengambil ID dari URL
    {
        // Cari produk berdasarkan product_id (karena ini primaryKey)
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Product not found.'
            ], 404); // Kode status HTTP 404 Not Found
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

        // Validasi input untuk update. product_id tidak perlu unik lagi kecuali jika diubah.
        $validator = Validator::make($request->all(), [
            // 'product_id' => 'sometimes|integer|unique:products,product_id,'.$id.',product_id', // Jika product_id bisa diubah
            'gender_id' => 'sometimes|integer|exists:genders,id', // 'sometimes' berarti opsional
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

        // Update produk dengan data yang valid
        $product->update($request->all()); // Menggunakan $request->all() karena sudah divalidasi

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
        ], 200); // Kode status HTTP 200 OK
    }
}