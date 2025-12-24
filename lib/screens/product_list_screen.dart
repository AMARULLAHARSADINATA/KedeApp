import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _loading = true;
  List products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await ApiService.getProducts();
    setState(() {
      products = data;
      _loading = false;
    });
  }

Future<void> _deleteProduct(int id) async {
  final res = await ApiService.deleteProduct(id);

  if (res['success'] == true) {
    _loadProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal menghapus produk'),
        backgroundColor: Colors.red,
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products',
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProductScreen()),
          );
          _loadProducts();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = products[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              p['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: kTextLightColor),
                            ),
                            const SizedBox(height: 8),
                            Text('Rp ${p['price']}',
                                style: const TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: kPrimaryColor),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProductScreen(product: p),
                            ),
                          );
                          _loadProducts();
                        },
                      ),
                      IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Hapus produk?'),
                            content: const Text('Data tidak bisa dikembalikan'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          _deleteProduct(p['id']);
                        }
                      },
                    ),

                    ],
                  ),
                );
              },
            ),
    );
  }
}
