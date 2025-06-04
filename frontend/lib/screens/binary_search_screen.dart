import 'package:flutter/material.dart';
import 'package:frontend/services/master_data_service.dart'; // Untuk memanggil API Binary Search
import 'package:frontend/models/subcategory_model.dart'; // Untuk model Subcategory

class BinarySearchScreen extends StatefulWidget {
  const BinarySearchScreen({super.key});

  @override
  State<BinarySearchScreen> createState() => _BinarySearchScreenState();
}

class _BinarySearchScreenState extends State<BinarySearchScreen> {
  final TextEditingController _idController = TextEditingController();
  final MasterDataService _masterDataService = MasterDataService();
  Subcategory? _foundSubcategory;
  String? _searchMessage;
  bool _isLoading = false;
  int? _searchSteps; // Untuk menampilkan jumlah langkah Binary Search

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _performBinarySearch() async {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Subcategory ID.')),
      );
      return;
    }

    final int? searchId = int.tryParse(_idController.text);
    if (searchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for ID.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _foundSubcategory = null;
      _searchMessage = null;
      _searchSteps = null;
    });

    final response =
        await _masterDataService.binarySearchSubcategoryById(searchId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response['success']) {
          _foundSubcategory = response['data'] as Subcategory;
          _searchMessage = response['message'] ?? 'Subcategory found.';
          _searchSteps = response['search_steps'] as int?;
        } else {
          _searchMessage = response['message'] ?? 'Subcategory not found.';
          _searchSteps = response['search_steps'] as int?;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Search Demo (Subcategory by ID)'),
        backgroundColor: Colors.purple[700], // Warna khusus untuk demo
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Demonstrasi Algoritma Binary Search di Backend Laravel.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Subcategory ID',
                hintText: 'e.g., 1, 2, 3...',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _performBinarySearch,
                    child: const Text('Perform Binary Search'),
                  ),
            const SizedBox(height: 24),
            if (_searchMessage != null)
              Text(
                _searchMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _foundSubcategory != null ? Colors.green : Colors.red,
                ),
              ),
            if (_searchSteps != null)
              Text(
                'Search completed in $_searchSteps steps.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),
            if (_foundSubcategory != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subcategory Found:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('ID: ${_foundSubcategory!.id}'),
                      Text('Name: ${_foundSubcategory!.name}'),
                      Text('Category ID: ${_foundSubcategory!.categoryId}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
