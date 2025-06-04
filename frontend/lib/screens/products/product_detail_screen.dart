import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart'; // Import model Product
import 'package:cached_network_image/cached_network_image.dart'; // Untuk loading gambar
// Import model data master
import 'package:frontend/models/category_model.dart';
import 'package:frontend/models/subcategory_model.dart';
import 'package:frontend/models/product_type_model.dart';
import 'package:frontend/models/colour_model.dart';
import 'package:frontend/models/usage_model.dart';
// import 'package:frontend/models/gender_model.dart'; // Jika digunakan, import di sini
import 'package:frontend/services/master_data_service.dart'; // Untuk mengambil data master
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

class ProductDetailScreen extends StatefulWidget {
  final Product product; // Menerima objek Product dari halaman sebelumnya

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final MasterDataService _masterDataService = MasterDataService();
  String _categoryName = 'Loading...';
  String _subcategoryName = 'Loading...';
  String _productTypeName = 'Loading...';
  String _colourName = 'Loading...';
  String _usageName = 'Loading...';
  // String _genderName = 'Loading...'; // Jika digunakan

  @override
  void initState() {
    super.initState();
    _loadRelatedData(); // Muat nama-nama dari ID
  }

  Future<void> _loadRelatedData() async {
    // Muat semua list master data yang diperlukan
    List<ProductCategory> categories = await _masterDataService.getCategories();
    List<Subcategory> subcategories =
        await _masterDataService.getSubcategories(); // Ambil semua subkategori
    List<ProductTypeModel> productTypes =
        await _masterDataService.getProductTypes(); // Ambil semua tipe produk
    List<Colour> colours = await _masterDataService.getColours();
    List<Usage> usages = await _masterDataService.getUsages();
    // List<Gender> genders = await _masterDataService.getGenders(); // Jika digunakan

    // Inisialisasi nama default sebagai 'Unknown'
    String tempCategoryName = 'Unknown Category';
    String tempSubcategoryName = 'Unknown Subcategory';
    String tempProductTypeName = 'Unknown Product Type';
    String tempColourName = 'Unknown Colour';
    String tempUsageName = 'Unknown Usage';
    // String tempGenderName = 'Unknown Gender'; // Jika digunakan

    // 1. Cari Colour dan Usage (Langsung dari product ID)
    try {
      Colour? colour =
          colours.firstWhere((col) => col.id == widget.product.colourId);
      tempColourName = colour.name;
    } catch (e) {
      if (kDebugMode)
        print(
            'ProductDetailScreen: Colour ID ${widget.product.colourId} not found.');
    }

    try {
      Usage? usage =
          usages.firstWhere((use) => use.id == widget.product.usageId);
      tempUsageName = usage.name;
    } catch (e) {
      if (kDebugMode)
        print(
            'ProductDetailScreen: Usage ID ${widget.product.usageId} not found.');
    }

    // 2. Telusuri rantai relasi untuk Category, Subcategory, Product Type
    // Dimulai dari ProductTypeModel karena products.product_type_id menunjuk ke sana
    ProductTypeModel? productType;
    try {
      productType = productTypes
          .firstWhere((pt) => pt.id == widget.product.productTypeId);
      tempProductTypeName = productType.name;
    } catch (e) {
      if (kDebugMode)
        print(
            'ProductDetailScreen: ProductType ID ${widget.product.productTypeId} not found.');
    }

    if (productType != null) {
      // Jika ProductType ditemukan, cari Subcategory-nya
      Subcategory? subcategory;
      try {
        subcategory = subcategories
            .firstWhere((sub) => sub.id == productType?.subcategoryId);
        tempSubcategoryName = subcategory.name;
      } catch (e) {
        if (kDebugMode)
          print(
              'ProductDetailScreen: Subcategory ID ${productType.subcategoryId} not found for ProductType ${productType.name}.');
      }

      if (subcategory != null) {
        // Jika Subcategory ditemukan, cari Category-nya
        ProductCategory? category;
        try {
          category =
              categories.firstWhere((cat) => cat.id == subcategory?.categoryId);
          tempCategoryName = category.name;
        } catch (e) {
          if (kDebugMode)
            print(
                'ProductDetailScreen: Category ID ${subcategory.categoryId} not found for Subcategory ${subcategory.name}.');
        }
      }
    }

    // 3. Cari Gender (jika digunakan)
    // try {
    //   Gender? gender = genders.firstWhere((gen) => gen.id == widget.product.genderId);
    //   tempGenderName = gender.name;
    // } catch (e) {
    //   if (kDebugMode) print('ProductDetailScreen: Gender ID ${widget.product.genderId} not found.');
    // }

    // Perbarui UI setelah semua data ditemukan
    if (mounted) {
      setState(() {
        _categoryName = tempCategoryName;
        _subcategoryName = tempSubcategoryName;
        _productTypeName = tempProductTypeName;
        _colourName = tempColourName;
        _usageName = tempUsageName;
        // _genderName = tempGenderName; // Jika digunakan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Judul Produk
            Text(
              widget.product.title,
              style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16.0),

            // Detail Produk (menggunakan nama dari data master)
            _buildDetailRow('Product ID', widget.product.productId.toString()),
            _buildDetailRow('Category', _categoryName),
            _buildDetailRow('Subcategory', _subcategoryName),
            _buildDetailRow('Product Type', _productTypeName),
            _buildDetailRow('Colour', _colourName),
            _buildDetailRow('Usage', _usageName),
            // _buildDetailRow('Gender', _genderName), // Jika digunakan

            const SizedBox(height: 24.0),

            // TODO: Tambahkan tombol "Add to Cart" atau fitur lainnya
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add to Cart (Coming Soon!)')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 50), // Tombol penuh lebar
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
