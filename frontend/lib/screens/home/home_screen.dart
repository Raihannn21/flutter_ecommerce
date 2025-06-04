import 'package:flutter/material.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter/foundation.dart'; // Import untuk kDebugMode
import 'dart:convert'; // Import untuk jsonDecode
import 'package:frontend/models/user.dart'; // Import untuk User model

import 'package:frontend/screens/admin/admin_product_screen.dart'; // Import AdminProductScreen
import 'package:frontend/screens/products/product_detail_screen.dart'; // <<<<<< PENTING: Import ProductDetailScreen

// Hapus import yang tidak diperlukan lagi jika file-nya sudah dihapus
// import 'package:ecommerce_app/widgets/app_drawer.dart';
// import 'package:ecommerce_app/screens/category_screen.dart';
// import 'package:ecommerce_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  User? _currentUser; // Variabel untuk menyimpan user yang login

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Panggil ini untuk memuat user saat HomeScreen dibuat
    _fetchProducts(); // Panggil ini untuk memuat produk
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat user yang login dari Shared Preferences
  Future<void> _loadCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        setState(() {
          _currentUser = User.fromJson(jsonDecode(userDataString));
        });
        if (kDebugMode) {
          print(
              'HomeScreen: Loaded user from prefs: ${_currentUser?.email} (Role: ${_currentUser?.role})');
        }
      } catch (e) {
        if (kDebugMode) {
          print('HomeScreen: Failed to parse user data from prefs: $e');
        }
        // Jika gagal parsing, hapus data user yang mungkin rusak
        await prefs.remove('user_data');
      }
    } else {
      if (kDebugMode) {
        print('HomeScreen: No user data found in prefs.');
      }
    }
  }

  void _onScroll() {
    // Memastikan tidak sedang memuat, ada halaman berikutnya, dan sudah mencapai akhir scroll
    if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            !_isLoading && // Pastikan tidak sedang memuat data awal
            !_isFetchingMore && // Pastikan tidak sedang memuat lebih banyak data
            _hasMore // Pastikan ada halaman berikutnya
        ) {
      _fetchMoreProducts(); // Panggil fungsi untuk memuat lebih banyak
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products.clear(); // Bersihkan produk saat refresh penuh
      _currentPage = 1; // Reset halaman ke 1
      _hasMore = true; // Asumsikan ada lebih banyak data
    });

    final response =
        await _productService.getProducts(page: _currentPage, perPage: 20);

    if (mounted) {
      if (response['success']) {
        setState(() {
          _products = response['data']
              as List<Product>; // Casting langsung ke List<Product>
          // Perbarui status _hasMore berdasarkan pagination metadata dari respons Laravel
          _hasMore = response['pagination']?['current_page'] <
              response['pagination']?['last_page'];
          _isLoading = false;
        });
        if (kDebugMode) {
          // Debug prints setelah setState
          print('HomeScreen: Products fetched successfully.');
          print('HomeScreen: Number of products received: ${_products.length}');
          if (_products.isNotEmpty) {
            print('HomeScreen: First product title: ${_products.first.title}');
          }
          print('HomeScreen: Has more pages: $_hasMore');
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load products.';
          _isLoading = false;
        });
        if (kDebugMode) {
          // Debug prints untuk error
          print('HomeScreen: Failed to fetch products: $_errorMessage');
        }
      }
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++; // Tambah nomor halaman
    final response =
        await _productService.getProducts(page: _currentPage, perPage: 20);

    if (mounted) {
      setState(() {
        _isFetchingMore = false; // Reset status loading
        if (response['success']) {
          _products.addAll(response['data']
              as List<Product>); // Tambahkan ke daftar yang sudah ada
          _hasMore = response['pagination']?['current_page'] <
              response['pagination']?['last_page'];
        } else {
          // Jika gagal memuat lebih banyak, tampilkan snackbar kecil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    response['message'] ?? 'Failed to load more products.')),
          );
          _currentPage--; // Kembalikan halaman jika gagal agar bisa coba lagi
        }
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true; // Set loading state saat logout
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token != null) {
      final response = await _authService.logout(token);
      if (response['success']) {
        await prefs.remove('auth_token'); // Hapus token dari SharedPreferences
        await prefs.remove('user_data'); // Hapus juga user data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Logout failed.')),
          );
        }
      }
    } else {
      // Jika token null saat coba logout
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active session to log out.')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget terpisah untuk Grid Produk, agar kode lebih rapi
  Widget _buildProductGrid() {
    if (_isLoading && _products.isEmpty) {
      // Ini untuk loading awal
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      // Jika ada error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _fetchProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_products.isEmpty && !_isLoading) {
      // Jika tidak ada produk
      return const Center(
        child: Text('No products found. Please add some from admin panel.'),
      );
    } else {
      return GridView.builder(
        controller:
            _scrollController, // Menggunakan scrollController untuk infinite scroll
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom per baris
          childAspectRatio: 0.7, // Rasio lebar/tinggi item
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _products.length +
            (_hasMore
                ? 1
                : 0), // Tambahkan 1 item untuk loading indicator/footer
        itemBuilder: (context, index) {
          if (index == _products.length) {
            // Ini adalah item terakhir, tampilkan loading atau pesan "No more products"
            return _isFetchingMore
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child:
                        _hasMore // Seharusnya tidak tercapai jika hasMore false dan tidak fetching
                            ? const Text('Loading more...')
                            : const Text('No more products to load.'),
                  );
          }

          final product = _products[index];
          return Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              // Membuat kartu bisa diklik
              onTap: () {
                // <<<<<<<<<< PERBAIKAN DI SINI: AKTIFKAN NAVIGASI
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                        product: product), // Meneruskan objek product
                  ),
                );
                // <<<<<<<<<< AKHIR PERBAIKAN
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0)),
                      child: CachedNetworkImage(
                        // Menggunakan CachedNetworkImage
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2.0)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2, // Batasi 2 baris
                          overflow: TextOverflow
                              .ellipsis, // Tambahkan ... jika terlalu panjang
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Product ID: ${product.productId}', // Contoh detail
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        // TODO: Tampilkan harga, kategori, dll.
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce App'), // Judul tetap
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        actions: [
          // Tombol Admin Panel, hanya jika user adalah Admin
          if (_currentUser != null && _currentUser!.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                // Navigasi ke AdminProductScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProductScreen()),
                ).then((value) {
                  // Refresh produk setelah kembali dari AdminProductScreen jika ada perubahan
                  if (value == true) {
                    _fetchProducts();
                  }
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isFetchingMore ? null : _fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
          ),
        ],
      ),
      body: _buildProductGrid(), // Langsung tampilkan Grid Produk
    );
  }
}
