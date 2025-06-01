<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Colour extends Model
{
    use HasFactory;

    protected $table = 'colours';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'name',
    ];

    // Opsional: Relasi ke Products jika Anda ingin melihat produk berdasarkan warna
    public function products()
    {
        return $this->hasMany(Product::class);
    }
}