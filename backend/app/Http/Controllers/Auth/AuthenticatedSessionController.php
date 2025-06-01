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
    // Ubah return type dari Response menjadi JsonResponse
    public function store(LoginRequest $request): JsonResponse // <<<<<<<<<< PERBAIKAN DI SINI
    {
        // Anda bisa hapus baris Log::info('Password (raw): ...'); di production
        Log::info('Login request received.');
        Log::info('Email: ' . $request->email);
        // Log::info('Password (raw): ' . $request->password);

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

        // Pastikan ini mengembalikan JsonResponse
        return response()->json([ // <<<<<<<<<< PERBAIKAN DI SINI: gunakan response()->json()
            'user' => $user,
            'token' => $token,
            'message' => 'Login successful.'
        ], 200); // Tambahkan status 200 OK secara eksplisit
    }

    /**
     * Destroy an authenticated session.
     */
    // Ubah return type dari Response menjadi JsonResponse
    public function destroy(Request $request): JsonResponse // <<<<<<<<<< PERBAIKAN DI SINI
    {
        // Pastikan pengguna terotentikasi dan memiliki token
        if (Auth::check()) {
            // Hapus token yang digunakan saat ini
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'message' => 'Logged out successfully.'
            ], 200); // Kode status 200 OK untuk sukses
        }

        // Jika tidak ada user yang terotentikasi (seharusnya dicegah oleh middleware auth:sanctum)
        // Namun, jika request datang tanpa token atau token tidak valid, middleware auth:sanctum
        // akan menangani ini dan mengembalikan 401 sebelum kode ini dieksekusi.
        // Bagian ini hanya akan tercapai jika Auth::check() entah bagaimana gagal di sini
        // padahal middleware auth:sanctum sudah lolos.
        return response()->json([
            'message' => 'No authenticated user found or token invalid.'
        ], 401);
    }
}