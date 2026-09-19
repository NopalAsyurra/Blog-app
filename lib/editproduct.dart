import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Editproduct extends StatefulWidget {
  final Map<String, dynamic> data;
  final http.Client? client;

  const Editproduct({super.key, required this.data, this.client});

  @override
  State<Editproduct> createState() => EditproductState();
}

class EditproductState extends State<Editproduct> {
  late final http.Client _client = widget.client ?? http.Client();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;

  bool isSaving = false;

  int? _parseCategoryId(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  Future<void> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('http://localhost:3000/api/categories'),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final data = result is List
            ? result
            : result is Map
            ? (result['data'] ?? result['categories'] ?? [])
            : <dynamic>[];

        setState(() {
          categories = data;
          selectedCategoryId = _parseCategoryId(
            widget.data['category_id'] ?? widget.data['categoryId'],
          );
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal memuat kategori')));
      }
    }
  }

  Future<void> updateProduct() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi semua data dan pilih kategori terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await _client.put(
        Uri.parse('http://localhost:3000/api/posts/${widget.data['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'category_id': selectedCategoryId,
          'nama': title,
          'title': title,
          'content': content,
        }),
      );

      if (!mounted) return;
      setState(() => isSaving = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil diupdate')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data gagal diupdate (${response.statusCode}): ${response.body}',
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
    titleController.text = (widget.data['title'] ?? widget.data['nama'] ?? '')
        .toString();
    contentController.text = (widget.data['content'] ?? '').toString();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Product")),
      body: ListView(
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
            onPressed: isSaving ? null : updateProduct,
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
    );
  }
}
