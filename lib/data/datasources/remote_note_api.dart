import 'dart:convert';
import 'package:http/http.dart' as http;

class RemoteNoteApi {
  final String endpoint = 'https://jsonplaceholder.typicode.com/posts';

  Future<bool> uploadNote({
    required String title,
    required String body,
    required String localId,
  }) async {
    try {
      final payload = jsonEncode({
        'title': title,
        'body': body,
        'userId': 1,
        'localId': localId,
      });

      final resp = await http
          .post(
        Uri.parse(endpoint),
        body: payload,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      )
          .timeout(const Duration(seconds: 8));

      return resp.statusCode == 201 || resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final resp = await http
          .delete(Uri.parse('$endpoint/$id'))
          .timeout(const Duration(seconds: 8));
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
