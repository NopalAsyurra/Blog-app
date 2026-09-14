import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final categoryController = TextEditingController();
  bool isSaving = false;

  Future<void> addCategory() async {
    if (categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori harus diisi')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': categoryController.text.trim(),
          'name': categoryController.text.trim(),
        }),
      );

      if (!mounted) return;
      setState(() => isSaving = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menambahkan kategori (${response.statusCode}): ${response.body}',
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
  void dispose() {
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Nama kategori'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : addCategory,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
