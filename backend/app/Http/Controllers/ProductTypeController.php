<?php

namespace App\Http\Controllers;

use App\Models\ProductType;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule; // Tambahkan ini

class ProductTypeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        // Opsi untuk filter berdasarkan subcategory_id
        $productTypes = ProductType::when($request->subcategory_id, function ($query, $subcategoryId) {
            return $query->where('subcategory_id', $subcategoryId);
        })->get();

        return response()->json([
            'message' => 'Product types retrieved successfully.',
            'data' => $productTypes
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => [
                'required',
                'string',
                'max:50',
                // Memastikan kombinasi nama dan subcategory_id unik
                Rule::unique('product_types')->where(function ($query) use ($request) {
                    return $query->where('subcategory_id', $request->subcategory_id);
                }),
            ],
            'subcategory_id' => 'required|integer|exists:subcategories,id', // Harus ada di tabel subcategories
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $productType = ProductType::create($request->all());
        return response()->json([
            'message' => 'Product type created successfully.',
            'data' => $productType
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $productType = ProductType::find($id);

        if (!$productType) {
            return response()->json([
                'message' => 'Product type not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Product type retrieved successfully.',
            'data' => $productType
        ], 200);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $productType = ProductType::find($id);

        if (!$productType) {
            return response()->json([
                'message' => 'Product type not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => [
                'sometimes',
                'required',
                'string',
                'max:50',
                // Memastikan kombinasi nama dan subcategory_id unik, kecuali untuk product type ini sendiri
                Rule::unique('product_types')->where(function ($query) use ($request) {
                    return $query->where('subcategory_id', $request->subcategory_id);
                })->ignore($productType->id),
            ],
            'subcategory_id' => 'sometimes|required|integer|exists:subcategories,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $productType->update($request->all());
        return response()->json([
            'message' => 'Product type updated successfully.',
            'data' => $productType
        ], 200);
    }

    public function destroy(string $id): JsonResponse
    {
        $productType = ProductType::find($id);

        if (!$productType) {
            return response()->json([
                'message' => 'Product type not found.'
            ], 404);
        }

        $productType->delete();
        return response()->json([
            'message' => 'Product type deleted successfully.'
        ], 200);
    }
}