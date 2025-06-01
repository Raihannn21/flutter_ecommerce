<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $table = 'categories'; // Pastikan nama tabel benar
    protected $primaryKey = 'id'; // Default, tapi bagus untuk eksplisit
    public $incrementing = true; // Default, tapi bagus untuk eksplisit
    protected $keyType = 'int'; // Default, tapi bagus untuk eksplisit

    protected $fillable = [
        'name',
    ];

    // Opsional: Relasi ke Subcategories
    public function subcategories()
    {
        return $this->hasMany(Subcategory::class);
    }
}