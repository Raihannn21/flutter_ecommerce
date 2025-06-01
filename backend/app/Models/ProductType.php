<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductType extends Model
{
    use HasFactory;

    protected $table = 'product_types';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'name',
        'subcategory_id',
    ];

    // Relasi ke Subcategory
    public function subcategory()
    {
        return $this->belongsTo(Subcategory::class);
    }

    // Relasi ke Products
    public function products()
    {
        return $this->hasMany(Product::class);
    }
}   