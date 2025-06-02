import 'package:flutter/material.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // <<<<<<<<<< PENTING: Tambahkan ini untuk jsonDecode
import 'package:frontend/models/user.dart'; // <<<<<<<<<< PENTING: Tambahkan ini
import 'package:frontend/screens/admin/admin_product_screen.dart'; // <<<<<<<<<< PENTING: Tambahkan ini

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

  User? _currentUser; // <<<<<<<<<< TAMBAHAN: Untuk menyimpan user yang login

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // <<<<<<<<<< TAMBAHAN: Panggil ini saat init
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // <<<<<<<<<< TAMBAHAN: FUNGSI UNTUK MEMUAT USER YANG LOGIN
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
  // <<<<<<<<<< AKHIR TAMBAHAN

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        !_isFetchingMore &&
        _hasMore) {
      _fetchMoreProducts();
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    final response =
        await _productService.getProducts(page: _currentPage, perPage: 20);

    if (mounted) {
      if (response['success']) {
        setState(() {
          _products = response['data'] as List<Product>;
          _hasMore = response['pagination']?['current_page'] <
              response['pagination']?['last_page'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load products.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMoreProducts() async {
    if (!_hasMore || _isFetchingMore) return;

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;
    final response =
        await _productService.getProducts(page: _currentPage, perPage: 20);

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
        await prefs
            .remove('user_data'); // <<<<<<<<<< PENTING: Hapus juga user_data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce App'),
        automaticallyImplyLeading: false,
        actions: [
          // <<<<<<<<<< PERBAIKAN: Tampilkan tombol Admin Panel secara kondisional
          if (_currentUser != null && _currentUser!.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
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
          // <<<<<<<<<< AKHIR PERBAIKAN

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
          ),
        ],
      ),
      body: _isLoading && _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                )
              : _products.isEmpty && !_isLoading
                  ? const Center(
                      child: Text(
                          'No products found. Please add some from admin panel.'),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _products.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Clicked on ${product.title}')),
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
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.0)),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image,
                                              size: 50),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    ),
    );
  }
}
