<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    // Set nama tabel secara eksplisit jika nama model tidak sesuai konvensi plural Laravel (Product -> products)
    protected $table = 'products';

    // Set primary key secara eksplisit jika bukan 'id'
    protected $primaryKey = 'product_id';

    // Primary key bukan auto-incrementing atau bukan integer, set to false
    // (sesuaikan jika product_id Anda memang SERIAL atau auto-increment)
    public $incrementing = true; // Jika product_id SERIAL
    protected $keyType = 'int'; // Jika product_id INTEGER

    // Kolom yang dapat diisi secara massal
    protected $fillable = [
        'product_id', // Jika Anda mengelola ID secara manual saat POST/PUT
        'gender_id',
        'product_type_id',
        'colour_id',
        'usage_id',
        'title',
        'image_url',
    ];

    // Definisi relasi (opsional, tapi baik untuk API)
    public function gender()
    {
        return $this->belongsTo(Gender::class);
    }

    public function productType()
    {
        return $this->belongsTo(ProductType::class);
    }

    public function colour()
    {
        return $this->belongsTo(Colour::class);
    }

    public function usage()
    {
        return $this->belongsTo(Usage::class);
    }
}