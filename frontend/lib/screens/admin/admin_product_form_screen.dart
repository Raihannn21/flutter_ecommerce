import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart'; // Import Product model jika ada

class AdminProductFormScreen extends StatelessWidget {
  final Product? product; // Bisa null jika menambah produk baru

  const AdminProductFormScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product == null ? 'Add New Product' : 'Edit Product'),
        backgroundColor: Colors.red[700], // Warna khusus admin
      ),
      body: Center(
        child: Text(
          product == null
              ? 'Form to add new product (Coming Soon!)'
              : 'Form to edit product: ${product!.title} (Coming Soon!)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
