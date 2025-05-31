import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/article_model.dart';

class NewsApiService {
  static const String _apiKey = '029dc39bbb694b2ab04fcca6247fec2c';
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _defaultCountryForTopHeadlines = 'us';

  Future<List<Article>> fetchTopHeadlines({
    String country = _defaultCountryForTopHeadlines,
    String? category,
  }) async {
    String url = '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey';
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all news' &&
        category.toLowerCase() != 'headline' &&
        category.toLowerCase() != 'top stories') {
      url += '&category=${category.toLowerCase()}';
    }
    print('Requesting URL (Top Headlines): $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'ok' && jsonData['articles'] != null) {
          final List articlesJson = jsonData['articles'] as List;
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Failed to load news: ${jsonData['message'] ?? 'Unknown API error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load news: Server responded with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching top headlines: $e');
      throw Exception('Failed to load news: $e');
    }
  }

  Future<List<Article>> searchNews(
    String query, {
    String language = 'en',
    String sortBy = 'relevancy',
    int pageSize = 20,
  }) async {
    if (query.isEmpty) return [];
    final String encodedQuery = Uri.encodeComponent(query);

    String url =
        '$_baseUrl/everything?q=$encodedQuery&language=$language&sortBy=$sortBy&pageSize=$pageSize&apiKey=$_apiKey';
    print('Requesting URL (Search): $url');

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'ok' && jsonData['articles'] != null) {
          final List articlesJson = jsonData['articles'] as List;
          return articlesJson
              .map((json) => Article.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Failed to search news: ${jsonData['message'] ?? 'Unknown API error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to search news: Server responded with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error searching news: $e');
      throw Exception('Failed to search news: $e');
    }
  }
}
