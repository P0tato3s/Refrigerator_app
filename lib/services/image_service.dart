import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  static const String _apiKey = 'bB6POFluldTfX6OMear9vUhwOVpBkH6f4P2B1FwRzndirbBad1FQkT3v';

  static Future<String?> fetchFoodImage(String foodName) async {
    final query = Uri.encodeComponent('$foodName food');
    final url = Uri.parse(
      'https://api.pexels.com/v1/search?query=$query&per_page=1',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': _apiKey,
      },
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final photos = data['photos'] as List<dynamic>?;

    if (photos == null || photos.isEmpty) {
      return null;
    }

    final first = photos.first as Map<String, dynamic>;
    final src = first['src'] as Map<String, dynamic>?;

    return src?['medium'] as String?;
  }
}