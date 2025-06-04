import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/services/master_data_service.dart';
import 'package:frontend/models/category_model.dart'; // Menggunakan category_model.dart
import 'package:frontend/models/subcategory_model.dart'; // Menggunakan subcategory_model.dart
import 'package:frontend/models/product_type_model.dart'; // Menggunakan product_type_model.dart
import 'package:frontend/models/colour_model.dart'; // Menggunakan colour_model.dart
import 'package:frontend/models/usage_model.dart'; // Menggunakan usage_model.dart
// import 'package:ecommerce_app/models/gender_model.dart'; // Jika tidak digunakan
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'dart:convert'; // Untuk jsonEncode jika diperlukan

class AdminProductFormScreen extends StatefulWidget {
  final Product? product; // Jika ada produk, ini adalah mode EDIT

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productIdController =
      TextEditingController(); // Untuk product_id (jika manual)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final ProductService _productService = ProductService();
  final MasterDataService _masterDataService = MasterDataService();

  bool _isLoading = false;
  String? _errorMessage;

  // Dropdown data lists
  List<ProductCategory> _categories = [];
  List<Subcategory> _subcategories = [];
  List<ProductTypeModel> _productTypes = [];
  List<Colour> _colours = [];
  List<Usage> _usages = [];
  // List<Gender> _genders = []; // Tidak digunakan sesuai permintaan user

  // Selected dropdown values (sekarang nullable)
  ProductCategory? _selectedCategory;
  Subcategory? _selectedSubcategory;
  ProductTypeModel? _selectedProductType;
  Colour? _selectedColour;
  Usage? _selectedUsage;
  // Gender? _selectedGender; // Tidak digunakan

  String? _adminToken; // Token admin untuk operasi CRUD

  @override
  void initState() {
    super.initState();
    _loadAdminTokenAndMasterData();
    _populateFormIfEditing();
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _titleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminTokenAndMasterData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Ambil token admin
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _adminToken = prefs.getString('auth_token');

      if (_adminToken == null) {
        _errorMessage = 'Admin token not found. Please re-login as admin.';
        if (mounted) setState(() {}); // Update UI with error message
        return;
      }

      // Muat semua data master
      _categories = await _masterDataService.getCategories();
      _colours = await _masterDataService.getColours();
      _usages = await _masterDataService.getUsages();
      // _genders = await _masterDataService.getGenders(); // Tidak digunakan

      if (kDebugMode) {
        print(
            'Master data loaded: Categories ${_categories.length}, Colours ${_colours.length}, Usages ${_usages.length}');
        if (_categories.isEmpty) print('WARNING: Categories list is empty!');
        if (_colours.isEmpty) print('WARNING: Colours list is empty!');
        if (_usages.isEmpty) print('WARNING: Usages list is empty!');
      }

      // Jika dalam mode edit, set nilai awal dropdown
      if (widget.product != null) {
        // Set selected dropdowns based on product data if editing
        // Ini harus dilakukan setelah data master dimuat

        // Set Colour
        try {
          _selectedColour =
              _colours.firstWhere((col) => col.id == widget.product!.colourId);
        } catch (e) {
          _selectedColour = null;
          if (kDebugMode)
            print(
                'Colour ID ${widget.product!.colourId} not found in loaded colours.');
        }
        // Set Usage
        try {
          _selectedUsage =
              _usages.firstWhere((use) => use.id == widget.product!.usageId);
        } catch (e) {
          _selectedUsage = null;
          if (kDebugMode)
            print(
                'Usage ID ${widget.product!.usageId} not found in loaded usages.');
        }

        // Untuk kategori, subkategori, tipe produk, perlu alur berantai
        // Asumsi genderId di produk adalah categoryId di database Laravel Anda
        // Dan productTypeId di produk adalah subcategoryId di database Anda
        ProductCategory? initialCategory;
        try {
          initialCategory = _categories.firstWhere((cat) =>
              cat.id ==
              widget.product!
                  .genderId); // genderId di Produk Laravel adalah ID Kategori
        } catch (e) {
          initialCategory = null;
          if (kDebugMode)
            print(
                'Category ID ${widget.product!.genderId} not found in loaded categories.');
        }

        if (initialCategory != null) {
          _selectedCategory = initialCategory;
          if (kDebugMode)
            print(
                'Loading subcategories for category ID: ${initialCategory.id}');
          await _loadSubcategories(initialCategory
              .id); // Muat subkategori berdasarkan kategori terpilih

          Subcategory? initialSubcategory;
          try {
            initialSubcategory = _subcategories.firstWhere((sub) =>
                sub.id ==
                widget.product!
                    .productTypeId); // product_type_id di Produk Laravel adalah ID Subkategori
          } catch (e) {
            initialSubcategory = null;
            if (kDebugMode)
              print(
                  'Subcategory ID ${widget.product!.productTypeId} not found in loaded subcategories.');
          }

          if (initialSubcategory != null) {
            _selectedSubcategory = initialSubcategory;
            if (kDebugMode)
              print(
                  'Loading product types for subcategory ID: ${initialSubcategory.id}');
            await _loadProductTypes(initialSubcategory
                .id); // Muat tipe produk berdasarkan subkategori terpilih

            ProductTypeModel? initialProductType;
            try {
              initialProductType = _productTypes.firstWhere((pt) =>
                  pt.id ==
                  widget.product!
                      .productTypeId); // product_type_id di Produk Laravel adalah ID ProductType
            } catch (e) {
              initialProductType = null;
              if (kDebugMode)
                print(
                    'ProductType ID ${widget.product!.productTypeId} not found in loaded product types.');
            }
            if (initialProductType != null) {
              _selectedProductType = initialProductType;
            }
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load master data: $e';
      if (kDebugMode) print(_errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFormIfEditing() {
    if (widget.product != null) {
      _productIdController.text = widget.product!.productId.toString();
      _titleController.text = widget.product!.title;
      _imageUrlController.text = widget.product!.imageUrl;
      // Dropdown values are set in _loadAdminTokenAndMasterData after master data is loaded
    }
  }

  Future<void> _loadSubcategories(int? categoryId) async {
    if (categoryId == null) {
      setState(() {
        _subcategories = [];
        _selectedSubcategory = null;
        _productTypes = [];
        _selectedProductType = null;
      });
      return;
    }
    setState(() {
      _isLoading = true; // Temporary loading for dropdowns
    });
    // Panggil API untuk subkategori
    _subcategories =
        await _masterDataService.getSubcategories(categoryId: categoryId);
    if (mounted) {
      setState(() {
        _selectedSubcategory = null; // Reset pilihan subkategori
        _productTypes = []; // Reset list tipe produk
        _selectedProductType = null; // Reset pilihan tipe produk
        _isLoading = false;
        if (kDebugMode)
          print(
              'Loaded ${_subcategories.length} subcategories for category ID $categoryId.');
      });
    }
  }

  Future<void> _loadProductTypes(int? subcategoryId) async {
    if (subcategoryId == null) {
      setState(() {
        _productTypes = [];
        _selectedProductType = null;
      });
      return;
    }
    setState(() {
      _isLoading = true; // Temporary loading for dropdowns
    });
    // Panggil API untuk tipe produk
    _productTypes =
        await _masterDataService.getProductTypes(subcategoryId: subcategoryId);
    if (mounted) {
      setState(() {
        _selectedProductType = null; // Reset pilihan tipe produk
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_adminToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Admin token missing. Please re-login.')),
        );
        return;
      }

      // Validasi dropdown selection
      if (_selectedCategory == null ||
          _selectedSubcategory == null ||
          _selectedProductType == null ||
          _selectedColour == null ||
          _selectedUsage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select all required fields.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> productData = {
        'gender_id': _selectedCategory!
            .id, // Asumsi gender_id di Laravel adalah category_id di Flutter
        'product_type_id': _selectedProductType!.id, // ProductTypeModel ID
        'colour_id': _selectedColour!.id,
        'usage_id': _selectedUsage!.id,
        'title': _titleController.text,
        'image_url': _imageUrlController.text,
      };

      Map<String, dynamic> response;
      if (widget.product == null) {
        // Mode Tambah Produk Baru
        // product_id di Laravel adalah PRIMARY KEY, jadi harus disediakan jika tidak SERIAL.
        // Jika SERIAL, Laravel akan mengurusnya.
        // Untuk skema Anda, product_id adalah INTEGER PRIMARY KEY, jadi harus disediakan.
        if (_productIdController.text.isNotEmpty) {
          productData['product_id'] = int.parse(_productIdController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Product ID is required for new product.')),
          );
          if (mounted)
            setState(() {
              _isLoading = false;
            });
          return;
        }
        response =
            await _productService.createProduct(productData, _adminToken!);
      } else {
        // Mode Edit Produk
        response = await _productService.updateProduct(
            widget.product!.productId.toString(), productData, _adminToken!);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.product == null
                    ? 'Product added!'
                    : 'Product updated!')),
          );
          Navigator.pop(
              context, true); // Kembali ke AdminProductScreen dan refresh
        } else {
          String errorMessage = response['message'] ?? 'Operation failed.';
          if (response['errors'] != null) {
            response['errors'].forEach((key, value) {
              errorMessage += '\n${value[0]}';
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product == null ? 'Add New Product' : 'Edit Product'),
        backgroundColor: Colors.red[700],
      ),
      body: _isLoading &&
              _categories.isEmpty &&
              _errorMessage ==
                  null // Tampilkan loading penuh jika data master belum dimuat
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      ElevatedButton(
                        onPressed:
                            _loadAdminTokenAndMasterData, // Coba muat ulang
                        child: const Text('Retry Load Data'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _productIdController,
                          decoration:
                              const InputDecoration(labelText: 'Product ID'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (widget.product == null) {
                              // Hanya required saat menambah baru
                              if (value == null || value.isEmpty) {
                                return 'Please enter Product ID';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                            }
                            return null;
                          },
                          enabled: widget.product == null, // Disable jika edit
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _imageUrlController,
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter image URL';
                            }
                            final uri =
                                Uri.tryParse(value); // <<<<<< PERBAIKAN DI SINI
                            if (uri == null || !uri.hasAbsolutePath) {
                              // Cek apakah uri valid dan punya absolute path
                              return 'Please enter a valid URL';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Kategori
                        DropdownButtonFormField<ProductCategory>(
                          value: _selectedCategory,
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                          items: _categories.map((category) {
                            return DropdownMenuItem<ProductCategory>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedSubcategory = null; // Reset subcategory
                              _selectedProductType = null; // Reset product type
                              _loadSubcategories(
                                  value?.id); // Muat subkategori baru
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Subkategori (tergantung Kategori terpilih)
                        DropdownButtonFormField<Subcategory>(
                          value: _selectedSubcategory,
                          decoration:
                              const InputDecoration(labelText: 'Subcategory'),
                          items: _subcategories.map((subcategory) {
                            return DropdownMenuItem<Subcategory>(
                              value: subcategory,
                              child: Text(subcategory.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubcategory = value;
                              _selectedProductType = null; // Reset product type
                              _loadProductTypes(
                                  value?.id); // Muat tipe produk baru
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subcategory';
                            }
                            return null;
                          },
                          // Disable jika tidak ada kategori terpilih atau subkategori belum dimuat
                          isDense: _subcategories.isEmpty,
                          hint: _subcategories.isEmpty &&
                                  _selectedCategory != null
                              ? const Text('Loading subcategories...')
                              : const Text('Select a subcategory'),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Tipe Produk (tergantung Subkategori terpilih)
                        DropdownButtonFormField<ProductTypeModel>(
                          value: _selectedProductType,
                          decoration:
                              const InputDecoration(labelText: 'Product Type'),
                          items: _productTypes.map((productType) {
                            return DropdownMenuItem<ProductTypeModel>(
                              value: productType,
                              child: Text(productType.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProductType = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a product type';
                            }
                            return null;
                          },
                          isDense: _productTypes.isEmpty,
                          hint: _productTypes.isEmpty &&
                                  _selectedSubcategory != null
                              ? const Text('Loading product types...')
                              : const Text('Select a product type'),
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Warna
                        DropdownButtonFormField<Colour>(
                          value: _selectedColour,
                          decoration:
                              const InputDecoration(labelText: 'Colour'),
                          items: _colours.map((colour) {
                            return DropdownMenuItem<Colour>(
                              value: colour,
                              child: Text(colour.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedColour = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a colour';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dropdown Penggunaan
                        DropdownButtonFormField<Usage>(
                          value: _selectedUsage,
                          decoration: const InputDecoration(labelText: 'Usage'),
                          items: _usages.map((usage) {
                            return DropdownMenuItem<Usage>(
                              value: usage,
                              child: Text(usage.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUsage = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a usage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submitForm,
                                child: Text(widget.product == null
                                    ? 'Add Product'
                                    : 'Update Product'),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
