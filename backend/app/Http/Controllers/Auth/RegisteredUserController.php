<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\Request;
// use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;

class RegisteredUserController extends Controller
{
    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    // <<<<<<<<<< PERBAIKAN: Ubah return type dari Response menjadi JsonResponse
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password), // <<<<<<<<<< PERBAIKAN: Gunakan $request->password, bukan $request->string('password')
            'role' => 'user', // <<<<<<<<<< Pastikan ini ada untuk set default role
        ]);

        event(new Registered($user));

        Auth::login($user);

        // <<<<<<<<<< PERBAIKAN: Ganti return response()->noContent() dengan JSON response
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'message' => 'Registration successful.'
        ], 201); // Kode status 201 Created
        // <<<<<<<<<< AKHIR PERBAIKAN
    }
}