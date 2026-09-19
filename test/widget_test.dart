// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lat_rpl_3/homepage.dart';

class FakeHttpClient extends http.BaseClient {
  final List<Map<String, dynamic>> products = [
    {'id': 1, 'title': 'Judul Lama', 'content': 'Isi lama', 'category_id': 2},
  ];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;

    if (uri.path == '/api/categories' && request.method == 'GET') {
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'data': [
                {'id': 2, 'nama': 'Elektronik'},
              ],
            }),
          ),
        ),
        200,
      );
    }

    if (uri.path == '/api/posts' && request.method == 'GET') {
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'data': products}))),
        200,
      );
    }

    if (uri.path == '/api/posts/1' && request.method == 'PUT') {
      final body = await request.finalize().transform(utf8.decoder).join();
      final payload = jsonDecode(body);
      products[0]['title'] = payload['title'];
      products[0]['content'] = payload['content'];
      products[0]['category_id'] = payload['category_id'];

      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({'success': true}))),
        200,
      );
    }

    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 404);
  }
}

void main() {
  testWidgets('HomePage refreshes after successful edit', (
    WidgetTester tester,
  ) async {
    final client = FakeHttpClient();

    await tester.pumpWidget(MaterialApp(home: HomePage(client: client)));
    await tester.pumpAndSettle();

    expect(find.text('Judul Lama'), findsOneWidget);

    await tester.tap(find.text('Judul Lama'));
    await tester.pumpAndSettle();

    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'Judul Baru');
    await tester.pump();

    final contentField = find.byType(TextField).at(1);
    await tester.enterText(contentField, 'Isi baru');
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(client.products.first['title'], 'Judul Baru');
    expect(find.text('Judul Baru'), findsOneWidget);
  });
}
