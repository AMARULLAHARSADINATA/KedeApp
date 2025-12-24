import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class EditProductScreen extends StatefulWidget {
  final Map? product;
  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _name.text = widget.product!['name'];
      _desc.text = widget.product!['description'];
      _price.text = widget.product!['price'].toString();
    }
  }

  // ================== FIX UTAMA DI SINI ==================
Future<void> _save() async {
  final data = {
    'name': _name.text,
    'description': _desc.text,
    'price': _price.text,
  };

  Map<String, dynamic> response;

  if (isEdit) {
    response =
        await ApiService.updateProduct(widget.product!['id'], data);
  } else {
    response = await ApiService.createProduct(data);
  }

  if (response['success'] == true) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Barang berhasil diperbarui'
                : 'Barang berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Delay kecil agar snackbar terlihat sebelum pop
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.pop(context);
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan produk'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  // ================== BATAS FIX ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Product' : 'Add Product',
          style: const TextStyle(color: kTextColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField('Product Name', _name),
            _buildField('Description', _desc, maxLines: 3),
            _buildField(
              'Price',
              _price,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController c, {
    int maxLines = 1,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
