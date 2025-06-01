<?php

namespace App\Http\Controllers;

use App\Models\Colour;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class ColourController extends Controller
{
    public function index(): JsonResponse
    {
        $colours = Colour::all();
        return response()->json([
            'message' => 'Colours retrieved successfully.',
            'data' => $colours
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:50|unique:colours,name',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $colour = Colour::create($request->all());
        return response()->json([
            'message' => 'Colour created successfully.',
            'data' => $colour
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $colour = Colour::find($id);

        if (!$colour) {
            return response()->json([
                'message' => 'Colour not found.'
            ], 404);
        }

        return response()->json([
            'message' => 'Colour retrieved successfully.',
            'data' => $colour
        ], 200);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $colour = Colour::find($id);

        if (!$colour) {
            return response()->json([
                'message' => 'Colour not found.'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:50|unique:colours,name,'.$id,
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation Error.',
                'errors' => $validator->errors()
            ], 422);
        }

        $colour->update($request->all());
        return response()->json([
            'message' => 'Colour updated successfully.',
            'data' => $colour
        ], 200);
    }

    public function destroy(string $id): JsonResponse
    {
        $colour = Colour::find($id);

        if (!$colour) {
            return response()->json([
                'message' => 'Colour not found.'
            ], 404);
        }

        $colour->delete();
        return response()->json([
            'message' => 'Colour deleted successfully.'
        ], 200);
    }
}