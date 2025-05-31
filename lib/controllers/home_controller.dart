import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../data/models/article_model.dart';
import '../services/database_helper.dart';

class HomeController with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<String> _bookmarkedArticleUrls = {};

  final List<String> categories = [
    "Headline",
    "Top Stories",
    "All News",
    "Business",
    "Technology",
    "Sports",
    "Entertainment",
    "Health",
    "Science",
  ];
  String _selectedCategory = "Headline";
  String get selectedCategory => _selectedCategory;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _currentSearchQuery;
  String? get currentSearchQuery => _currentSearchQuery;

  String _currentSortBy = 'publishedAt';
  String get currentSortBy => _currentSortBy;

  final Map<String, String> sortByOptionsDisplay = const {
    'publishedAt': 'Terbaru',
    'relevancy': 'Relevansi',
    'popularity': 'Popularitas',
  };

  HomeController() {
    fetchTopHeadlinesByCategory(_selectedCategory);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _loadBookmarkedStatus() async {
    try {
      final bookmarks = await _dbHelper.getAllBookmarks();
      _bookmarkedArticleUrls = bookmarks
          .map((article) => article.url!)
          .where((url) => url.isNotEmpty)
          .toSet();
    } catch (e) {
      print("HomeController: Error loading bookmark statuses: $e");
    }
  }

  Future<void> fetchTopHeadlinesByCategory(String category) async {
    _selectedCategory = category;
    _isSearchActive = false;
    _currentSearchQuery = null;
    _setLoading(true);
    _setError(null);
    _articles = [];

    try {
      String? apiCategory;
      if (category.toLowerCase() != "all news" &&
          category.toLowerCase() != "headline" &&
          category.toLowerCase() != "top stories") {
        apiCategory = category.toLowerCase();
      }

      _articles = await _newsApiService.fetchTopHeadlines(
        country: 'us',
        category: apiCategory,
      );
      await _loadBookmarkedStatus();
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchArticles(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      fetchTopHeadlinesByCategory(
        categories.firstWhere(
          (cat) => cat.toLowerCase() == "headline",
          orElse: () => categories.first,
        ),
      );
      return;
    }

    _currentSearchQuery = trimmedQuery;
    _isSearchActive = true;
    _selectedCategory = "";
    _setLoading(true);
    _setError(null);
    _articles = [];

    try {
      _articles = await _newsApiService.searchNews(
        trimmedQuery,
        language: 'en',
        sortBy: _currentSortBy,
      );
      await _loadBookmarkedStatus();
    } catch (e) {
      _setError(e.toString());
      _articles = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSortOrder(String newSortBy) async {
    if (sortByOptionsDisplay.containsKey(newSortBy) &&
        _currentSortBy != newSortBy) {
      _currentSortBy = newSortBy;

      if (_isSearchActive &&
          _currentSearchQuery != null &&
          _currentSearchQuery!.isNotEmpty) {
        await searchArticles(_currentSearchQuery!);
      } else {
        notifyListeners();
      }
    }
  }

  void onCategorySelected(String category) {
    if (_selectedCategory != category || _articles.isEmpty || _isSearchActive) {
      fetchTopHeadlinesByCategory(category);
    }
  }

  bool isArticleBookmarked(String? articleUrl) {
    if (articleUrl == null || articleUrl.isEmpty) return false;
    return _bookmarkedArticleUrls.contains(articleUrl);
  }

  Future<void> toggleBookmark(Article article) async {
    if (article.url == null || article.url!.isEmpty) {
      _setError("Artikel tidak memiliki URL yang valid untuk di-bookmark.");
      notifyListeners();
      return;
    }

    final bool currentlyBookmarked = isArticleBookmarked(article.url);
    bool successOperation;

    if (currentlyBookmarked) {
      _bookmarkedArticleUrls.remove(article.url!);
      successOperation = await _dbHelper.removeBookmark(article.url!);
      if (!successOperation) {
        _bookmarkedArticleUrls.add(article.url!);
        _setError("Gagal menghapus bookmark dari database.");
      }
    } else {
      _bookmarkedArticleUrls.add(article.url!);
      successOperation = await _dbHelper.addBookmark(article);
      if (!successOperation) {
        _bookmarkedArticleUrls.remove(article.url!);
        _setError("Gagal menambahkan bookmark ke database.");
      }
    }
    notifyListeners();
  }
}
