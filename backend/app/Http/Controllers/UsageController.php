<?php

namespace App\Http\Controllers;

use App\Models\Usage;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class UsageController extends Controller
{
    public function index(): JsonResponse
    {
        $usages = Usage::all();
        return response()->json([
            'message' => 'Usages retrieved successfully.',
            'data' => $usages
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50|unique:usages,name',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $usage = Usage::create($request->all());
        return response()->json([
            'message' => 'Usage created successfully.',
            'data' => $usage
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $usage = Usage::find($id);

        if (!$usage) {
            return response()->json([
                'message' => 'Usage not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Usage retrieved successfully.',
            'data' => $usage
        ], 200);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $usage = Usage::find($id);

        if (!$usage) {
            return response()->json([
                'message' => 'Usage not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:50|unique:usages,name,'.$id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $usage->update($request->all());
        return response()->json([
            'message' => 'Usage updated successfully.',
            'data' => $usage
        ], 200);
    }

    public function destroy(string $id): JsonResponse
    {
        $usage = Usage::find($id);

        if (!$usage) {
            return response()->json([
                'message' => 'Usage not found.'
            ], 404);
        }

        $usage->delete();
        return response()->json([
            'message' => 'Usage deleted successfully.'
        ], 200);
    }
}