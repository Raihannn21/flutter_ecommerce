<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\NewPasswordController;
use App\Http\Controllers\Auth\PasswordResetLinkController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Auth\VerifyEmailController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ColourController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ProductTypeController;
use App\Http\Controllers\SubcategoryController;
use App\Http\Controllers\UsageController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', [RegisteredUserController::class, 'store'])
    ->middleware('guest');

Route::post('/login', [AuthenticatedSessionController::class, 'store'])
    ->middleware('guest');

Route::post('/forgot-password', [PasswordResetLinkController::class, 'store'])
    ->middleware('guest')
    ->name('password.email');

Route::post('/reset-password', [NewPasswordController::class, 'store'])
    ->middleware('guest')
    ->name('password.store');

Route::get('/verify-email/{id}/{hash}', VerifyEmailController::class)
    ->middleware(['auth', 'signed', 'throttle:6,1'])
    ->name('verification.verify');

Route::post('/email/verification-notification', function (Request $request) {
    $request->user()->sendEmailVerificationNotification();
    return response()->json(['status' => 'verification-link-sent']);
})
    ->middleware(['auth', 'throttle:6,1']);

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])
    ->middleware('auth:sanctum');

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{id}', [ProductController::class, 'show']);

Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{id}', [CategoryController::class, 'show']);

Route::get('/subcategories', [SubcategoryController::class, 'index']);
Route::get('/subcategories/{id}', [SubcategoryController::class, 'show']);

Route::get('/product-types', [ProductTypeController::class, 'index']);
Route::get('/product-types/{id}', [ProductTypeController::class, 'show']);

Route::get('/colours', [ColourController::class, 'index']);
Route::get('/colours/{id}', [ColourController::class, 'show']);

Route::get('/usages', [UsageController::class, 'index']);
Route::get('/usages/{id}', [UsageController::class, 'show']);

// Route untuk Admin
Route::middleware(['auth:sanctum', 'admin'])->group(function () {

    Route::post('/admin/products', [ProductController::class, 'store']);

    Route::put('/admin/products/{id}', [ProductController::class, 'update']); 

    Route::delete('/admin/products/{id}', [ProductController::class, 'destroy']);

    Route::post('/admin/categories', [CategoryController::class, 'store']);
    Route::put('/admin/categories/{id}', [CategoryController::class, 'update']);
    Route::delete('/admin/categories/{id}', [CategoryController::class, 'destroy']);

    Route::post('/admin/subcategories', [SubcategoryController::class, 'store']);
    Route::put('/admin/subcategories/{id}', [SubcategoryController::class, 'update']);
    Route::delete('/admin/subcategories/{id}', [SubcategoryController::class, 'destroy']);

    Route::post('/admin/product-types', [ProductTypeController::class, 'store']);
    Route::put('/admin/product-types/{id}', [ProductTypeController::class, 'update']);
    Route::delete('/admin/product-types/{id}', [ProductTypeController::class, 'destroy']);

    Route::post('/admin/colours', [ColourController::class, 'store']);
    Route::put('/admin/colours/{id}', [ColourController::class, 'update']);
    Route::delete('/admin/colours/{id}', [ColourController::class, 'destroy']);

    Route::post('/admin/usages', [UsageController::class, 'store']);
    Route::put('/admin/usages/{id}', [UsageController::class, 'update']);
    Route::delete('/admin/usages/{id}', [UsageController::class, 'destroy']);
});
