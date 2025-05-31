// lib/controllers/bookmark_controller.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../data/models/article_model.dart';

class BookmarkController with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _bookmarkedArticles = [];
  List<Article> get bookmarkedArticles => _bookmarkedArticles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BookmarkController() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookmarkedArticles = await _dbHelper.getAllBookmarks();
    } catch (e) {
      _errorMessage = "Gagal memuat bookmark: ${e.toString()}";
      _bookmarkedArticles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addArticleToBookmark(Article article) async {
    if (article.url == null) return;
    bool success = await _dbHelper.addBookmark(article);
    if (success) {
      if (!_bookmarkedArticles.any((a) => a.url == article.url)) {
        _bookmarkedArticles.insert(0, article);
      }
      notifyListeners();
    }
  }

  Future<void> removeArticleFromBookmark(Article article) async {
    if (article.url == null) return;
    bool success = await _dbHelper.removeBookmark(article.url!);
    if (success) {
      _bookmarkedArticles.removeWhere((a) => a.url == article.url);
      notifyListeners();
    }
  }

  Future<bool> checkIsBookmarked(String articleUrl) async {
    return await _dbHelper.isBookmarked(articleUrl);
  }
}
