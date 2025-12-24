import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final name = TextEditingController();
  final price = TextEditingController();
  final desc = TextEditingController();

  Future _save() async {
    await ApiService.createProduct({
      'name': name.text,
      'price': price.text,
      'description': desc.text,
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: price, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('SAVE')),
          ],
        ),
      ),
    );
  }
}
