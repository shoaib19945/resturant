import 'dart:convert';
import 'dart:io';

import 'package:restaurant_app/core/app_config.dart';
import 'exception_handler.dart';

class ApiClient {
  ApiClient({required this.headers});

  final Map<String, String> headers;

  static const String _userId = '1f60cddc-ae03-4430-b8d7-deb6bf63846c';
  static const String _latlng = '29.3800453,47.9744896';

  Future<Map<String, dynamic>> searchRestaurants({
    String query = '',
    String categoryId = '',
    int page = 1,
    int perPage = 20,
  }) async {

    final uri = Uri.parse(
      '${AppConfig.defaultBaseUrl}/restaurant/search'
          '?lang=en&storeCode=KW'
          '&page=$page'
          '&perPage=$perPage'
          '&q=${Uri.encodeQueryComponent(query)}'
          '&macroCategoryId='
          '&nearBy='
          '&sortBy=1'
          '&homeManagementId='
          '&latlng=$_latlng'
          '&userId=$_userId'
          '&calories='
          '&carbs='
          '&proteins='
          '&fats='
          '&isCheat=0',
    );

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);

      final request = await client.postUrl(uri);

      _applyHeaders(request);

      final payload = {
        "categoryId": categoryId,
      };

      print("URL => $uri");
      print("BODY => ${jsonEncode(payload)}");

      request.write(jsonEncode(payload));

      final response = await request.close();

      final body = await response.transform(utf8.decoder).join();

      print("STATUS => ${response.statusCode}");
      print("RESPONSE => $body");

      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }

      throw ApiException(
        'Server returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getRestaurantDetail(int restaurantId) async {
    final uri = Uri.parse(
      '${AppConfig.defaultBaseUrl}/restaurant/details'
          '?lang=en'
          '&storeCode=KW'
          '&currencyCode=KD'
          '&restaurantId=$restaurantId'
          '&userId=$_userId'
          '&latlng=$_latlng',
    );

    try {
      final client = HttpClient();

      final request = await client.getUrl(uri);

      _applyHeaders(request);

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(body) as Map<String, dynamic>;
          print(decoded);
          print('decoded');

        if (decoded['data'] is Map<String, dynamic>) {
          return decoded['data'] as Map<String, dynamic>;
        }

        return decoded;
      }

      throw ApiException(
        'Server returned ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  void _applyHeaders(HttpClientRequest request) {
    headers.forEach((key, value) {
      request.headers.set(key, value);
    });

    request.headers.contentType = ContentType.json;
  }
}