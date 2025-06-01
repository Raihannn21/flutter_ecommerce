<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::all();
        return response()->json([
            'message' => 'Categories retrieved successfully.',
            'data' => $categories
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50|unique:categories,name',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $category = Category::create($request->all());
        return response()->json([
            'message' => 'Category created successfully.',
            'data' => $category
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'message' => 'Category not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Category retrieved successfully.',
            'data' => $category
        ], 200);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'message' => 'Category not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:50|unique:categories,name,'.$id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $category->update($request->all());
        return response()->json([
            'message' => 'Category updated successfully.',
            'data' => $category
        ], 200);
    }

    public function destroy(string $id): JsonResponse
    {
        $category = Category::find($id);

        if (!$category) {
            return response()->json([
                'message' => 'Category not found.'
            ], 404);
        }

        $category->delete();
        return response()->json([
            'message' => 'Category deleted successfully.'
        ], 200);
    }
}