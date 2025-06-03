<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse; 
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Log; 


class AuthenticatedSessionController extends Controller
{
    /**
     * Handle an incoming authentication request.
     */
    public function store(LoginRequest $request): JsonResponse
    {
        Log::info('Login request received.');
        Log::info('Email: ' . $request->email);

        if ($request->wantsJson()) {
            Log::info('Request wants JSON (from store method).');
        } else {
            Log::info('Request does NOT want JSON (from store method).');
        }

        try {
            $request->authenticate();
            Log::info('Authentication successful.');
        } catch (ValidationException $e) {
            Log::error('Authentication failed due to validation: ' . $e->getMessage());
            throw $e;
        } catch (\Exception $e) {
            Log::error('Authentication failed with unexpected error: ' . $e->getMessage());
            throw $e;
        }

        $user = $request->user();
        $token = $user->createToken('auth_token')->plainTextToken;

        Log::info('User authenticated: ' . $user->email);
        Log::info('Token created.');
        return response()->json([ 
            'user' => $user,
            'token' => $token,
            'message' => 'Login successful.'
        ], 200);
    }

    /**
     * Destroy an authenticated session.
     */
    public function destroy(Request $request): JsonResponse
    {
        if (Auth::check()) {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'message' => 'Logged out successfully.'
            ], 200);
        }
        return response()->json([
            'message' => 'No authenticated user found or token invalid.'
        ], 401);
    }
}