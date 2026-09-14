import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lat_rpl_3/editproduct.dart';
import 'dart:convert';

import 'package:lat_rpl_3/tambah%20product.dart';
import 'package:lat_rpl_3/tambah%20kategori.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List products = [];

  Future<void> getDataProduct() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/posts'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        final data = result is List
            ? result
            : result is Map && result['data'] is List
            ? result['data']
            : result is Map && result['posts'] is List
            ? result['posts']
            : <dynamic>[];

        if (mounted) {
          setState(() => products = data);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data gagal diambil: ${response.statusCode} ${response.body}',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Koneksi API gagal: $error')));
      }
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/api/posts/$id'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Produk berhasil dihapus')));

      setState(() => products.removeWhere((product) => product['id'] == id));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus produk')));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final itemproduct = products[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editproduct(data: itemproduct),
                  ),
                );
              },
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.article)),
                title: Text(
                  (itemproduct['title'] ?? itemproduct['nama'] ?? 'Tanpa judul')
                      .toString(),
                ),
                subtitle: Text(
                  (itemproduct['content'] ?? '').toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  onPressed: () => deleteProduct(itemproduct['id']),
                  icon: Icon(Icons.delete),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'tambah-kategori',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryPage()),
              );
            },
            tooltip: 'Tambah kategori',
            child: const Icon(Icons.category),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'tambah-produk',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductPage()),
              );
              if (result == true) {
                getDataProduct();
              }
            },
            tooltip: 'Tambah produk',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
