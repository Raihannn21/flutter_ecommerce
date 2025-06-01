<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth; // Tambahkan ini

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        // 1. Cek apakah pengguna sudah login
        if (!Auth::check()) {
            // Jika belum login, kirim respons 401 Unauthorized
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        // 2. Cek role pengguna yang sedang login
        // Pastikan model User memiliki kolom 'role' dan sudah ditambahkan ke $fillable
        if (Auth::user()->role !== 'admin') {
            // Jika role bukan 'admin', kirim respons 403 Forbidden
            return response()->json(['message' => 'Unauthorized. Admin access required.'], 403);
        }

        // Jika sudah login dan role adalah 'admin', lanjutkan request
        return $next($request);
    }
}