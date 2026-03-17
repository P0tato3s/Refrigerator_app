import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _accessKey = 'LzSvjNqYDOLPvm43g4II0deBmElJlG5SQHbbM7umxXo';

  static Future<String?> fetchFoodImage(String foodName) async {
    final trimmed = foodName.trim();
    if (trimmed.isEmpty) return null;

    final query = Uri.encodeComponent(trimmed);
    final url = Uri.parse(
      'https://api.unsplash.com/search/photos'
          '?query=$query'
          '&per_page=1'
          '&orientation=squarish'
          '&client_id=$_accessKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        return null;
      }

      final first = results.first as Map<String, dynamic>;
      final urls = first['urls'] as Map<String, dynamic>?;

      return urls?['small'] as String?;
    } catch (_) {
      return null;
    }
  }
}