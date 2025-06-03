<?php

namespace App\Http\Controllers;

use App\Models\Subcategory;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class SubcategoryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $subcategories = Subcategory::when($request->category_id, function ($query, $categoryId) {
            return $query->where('category_id', $categoryId);
        })->get();

        return response()->json([
            'message' => 'Subcategories retrieved successfully.',
            'data' => $subcategories
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => [
                'required',
                'string',
                'max:50',
                Rule::unique('subcategories')->where(function ($query) use ($request) {
                    return $query->where('category_id', $request->category_id);
                }),
            ],
            'category_id' => 'required|integer|exists:categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $subcategory = Subcategory::create($request->all());
        return response()->json([
            'message' => 'Subcategory created successfully.',
            'data' => $subcategory
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $subcategory = Subcategory::find($id);

        if (!$subcategory) {
            return response()->json([
                'message' => 'Subcategory not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Subcategory retrieved successfully.',
            'data' => $subcategory
        ], 200);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $subcategory = Subcategory::find($id);

        if (!$subcategory) {
            return response()->json([
                'message' => 'Subcategory not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => [
                'sometimes',
                'required',
                'string',
                'max:50',
                Rule::unique('subcategories')->where(function ($query) use ($request) {
                    return $query->where('category_id', $request->category_id);
                })->ignore($subcategory->id),
            ],
            'category_id' => 'sometimes|required|integer|exists:categories,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $subcategory->update($request->all());
        return response()->json([
            'message' => 'Subcategory updated successfully.',
            'data' => $subcategory
        ], 200);
    }

    public function destroy(string $id): JsonResponse
    {
        $subcategory = Subcategory::find($id);

        if (!$subcategory) {
            return response()->json([
                'message' => 'Subcategory not found.'
            ], 404);
        }

        $subcategory->delete();
        return response()->json([
            'message' => 'Subcategory deleted successfully.'
        ], 200);
    }
}