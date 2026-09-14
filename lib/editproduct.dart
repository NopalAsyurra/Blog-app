import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Editproduct extends StatefulWidget {
  final Map<String, dynamic> data;

  const Editproduct({super.key, required this.data});

  @override
  State<Editproduct> createState() => EditproductState();
}

class EditproductState extends State<Editproduct> {
  late final titleController = TextEditingController(
    text: widget.data['title'],
  );
  late final contentController = TextEditingController(
    text: widget.data['content'] ?? '',
  );

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
        selectedCategoryId = int.tryParse(
          (widget.data['category_id'] ?? '').toString(),
        );
      });
    }
  }

  Future<void> updateProduct() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Pilih kategori terlebih dahulu')));
      return;
    }
    setState(() => isSaving = true);

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/posts/${widget.data['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category_id': selectedCategoryId.toString(),
        'title': titleController.text,
        'content': contentController.text,
      }),
    );
    setState(() => isSaving = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(
        context,
      ); // Kembali ke halaman sebelumnya setelah berhasil menyimpan
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data berhasil diupdate')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data gagal diupdate')));
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
              final categoryId = int.tryParse(category['id'].toString());
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
