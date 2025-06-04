import 'package:flutter/material.dart';
import 'package:frontend/services/product_service.dart'; // Import ProductService
import 'package:frontend/models/product.dart'; // Import model Product
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:frontend/screens/admin/admin_product_form_screen.dart'; // Import AdminProductFormScreen
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan token admin

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _deleteProduct(Product product) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${product.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting product...')),
      );
      String? adminToken = await _getAdminTokenFromPrefs();

      if (adminToken != null) {
        final response = await _productService.deleteProduct(
            product.productId.toString(), adminToken);

        if (mounted) {
          if (response['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deleted successfully!')),
            );
            _fetchProducts(); // Refresh daftar produk
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(response['message'] ?? 'Failed to delete product.')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Admin token not found. Please re-login.')),
        );
      }
    }
  }

  Future<String?> _getAdminTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _navigateToAddEditProduct({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductFormScreen(product: product),
      ),
    );

    if (result == true) {
      // Jika formulir berhasil menyimpan, refresh daftar
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Products'),
        backgroundColor: Colors.red[700], // Warna khusus untuk Admin
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchProducts,
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
                      child: Text('No products found.'),
                    )
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                            0.75, // Sedikit lebih tinggi untuk tombol aksi
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
                                      : const Text('No more products.'),
                                );
                        }

                        final product = _products[index];
                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
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
                                    Text(
                                      'ID: ${product.productId}',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _navigateToAddEditProduct(
                                        product: product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteProduct(product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _navigateToAddEditProduct(), // Navigasi ke form tambah produk
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
