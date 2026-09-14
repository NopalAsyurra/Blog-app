import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  List categories = [];
  int? selectedCategoryId;
  bool isSaving = false;

  Future<void> getCategories() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/categories'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      setState(() {
        categories = result is List ? result : result['data'] ?? [];
      });
    }
  }

  Future<void> addProduct() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi semua data dan pilih kategori terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category_id': selectedCategoryId.toString(),
          'nama': titleController.text.trim(),
          'title': titleController.text.trim(),
          'content': contentController.text.trim(),
        }),
      );

      if (!mounted) return;
      setState(() => isSaving = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menyimpan data')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data (${response.statusCode}): ${response.body}',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Koneksi API gagal: $error')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: categories.map<DropdownMenuItem<int>>((category) {
                final categoryId = int.tryParse(
                  (category['id'] ?? category['category_id']).toString(),
                );
                return DropdownMenuItem<int>(
                  value: categoryId,
                  child: Text(
                    (category['nama'] ?? category['name'] ?? '').toString(),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedCategoryId = value);
              },
            ),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : addProduct,
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
