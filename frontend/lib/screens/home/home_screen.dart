import 'package:flutter/material.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:frontend/models/user.dart';

import 'package:frontend/screens/admin/admin_product_screen.dart';
import 'package:frontend/screens/products/product_detail_screen.dart';

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

  User? _currentUser;

  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchProducts();
    _scrollController.addListener(_onScroll);

    // <<<<<<<<<< TAMBAHKAN LISTENER UNTUK SEARCH BAR
    _searchController.addListener(_onSearchChanged);
    // <<<<<<<<<< AKHIR TAMBAHAN
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // <<<<<<<<<< DISPOSE SEARCH CONTROLLER
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // <<<<<<<<<< AKHIR DISPOSE
    super.dispose();
  }

  // <<<<<<<<<< FUNGSI BARU UNTUK MENDETEKSI PERUBAHAN SEARCH BAR
  void _onSearchChanged() {
    // Debounce search input untuk menghindari terlalu banyak request
    // Ini adalah cara sederhana, untuk yang lebih canggih bisa pakai Timer
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text != _currentSearchQuery) {
        // Cek lagi setelah delay
        setState(() {
          _currentSearchQuery = _searchController.text;
          _isSearching = _currentSearchQuery.isNotEmpty;
        });
        _fetchProducts(); // Panggil ulang fetchProducts dengan query baru
      }
    });
  }
  // <<<<<<<<<< AKHIR FUNGSI BARU

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
        await prefs.remove('user_data');
      }
    } else {
      if (kDebugMode) {
        print('HomeScreen: No user data found in prefs.');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        !_isFetchingMore &&
        _hasMore) {
      _fetchMoreProducts();
    }
  }

  // <<<<<<<<<< PERUBAHAN: Panggil ProductService.binarySearchProductsBySubcategoryName
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products.clear(); // Bersihkan produk saat refresh penuh
      _currentPage = 1; // Reset halaman ke 1
      _hasMore = true; // Asumsikan ada lebih banyak data
    });

    final response =
        await _productService.binarySearchProductsBySubcategoryName(
      // <<<<<< Panggil metode Binary Search Subcategory
      page: _currentPage,
      perPage: 20,
      searchQuery: _currentSearchQuery, // <<<<<< Kirim query pencarian
    );

    if (mounted) {
      if (response['success']) {
        setState(() {
          _products = response['data'] as List<Product>;
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

  // <<<<<<<<<< PERUBAHAN: Panggil ProductService.binarySearchProductsBySubcategoryName
  Future<void> _fetchMoreProducts() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;
    final response =
        await _productService.binarySearchProductsBySubcategoryName(
      // <<<<<< Panggil metode Binary Search Subcategory
      page: _currentPage,
      perPage: 20,
      searchQuery: _currentSearchQuery, // <<<<<< Kirim query pencarian
    );

    if (mounted) {
      setState(() {
        _isFetchingMore = false;
        if (response['success']) {
          _products.addAll(response['data'] as List<Product>);
          _hasMore = response['pagination']?['current_page'] <
              response['pagination']?['last_page'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    response['message'] ?? 'Failed to load more products.')),
          );
          _currentPage--;
        }
      });
    }
  }
  // <<<<<<<<<< AKHIR PERUBAHAN

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token != null) {
      final response = await _authService.logout(token);
      if (response['success']) {
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
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

  Widget _buildProductGrid() {
    if (_isLoading && _products.isEmpty && _currentSearchQuery.isEmpty) {
      // Tambah kondisi untuk search
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
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
      // Jika tidak ada produk dan tidak loading
      return Center(
        // Tambah Center untuk pesan ini
        child: Text(
          _currentSearchQuery.isEmpty
              ? 'No products found. Please add some from admin panel.'
              : 'No products found for "${_currentSearchQuery}".', // Pesan jika hasil search kosong
        ),
      );
    } else {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            // Ini adalah item terakhir, tampilkan loading atau pesan "No more products"
            return _isFetchingMore
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: _hasMore
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0)),
                      child: CachedNetworkImage(
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Product ID: ${product.productId}',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
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
        title: _isSearching // Tampilkan search bar atau judul
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search subcategories...', // <<<<<< UBAH HINT TEXT
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _currentSearchQuery = '';
                              _isSearching = false;
                            });
                            _fetchProducts(); // Muat ulang semua produk
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
              )
            : const Text('E-commerce App'),
        automaticallyImplyLeading: false,
        actions: [
          // Tombol Search (untuk mengaktifkan/menonaktifkan search bar)
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  // Jika search bar ditutup, bersihkan query dan refresh
                  _searchController.clear();
                  _currentSearchQuery = '';
                  _fetchProducts();
                }
              });
            },
          ),
          // Tombol Admin Panel, hanya jika user adalah Admin
          if (_currentUser != null && _currentUser!.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminProductScreen()),
                ).then((value) {
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
      body: _buildProductGrid(),
    );
  }
}
