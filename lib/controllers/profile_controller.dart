// lib/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../routes/route_name.dart';

class ProfileController with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  String? get profileImagePath => _userData != null
      ? _userData![DatabaseHelper.columnProfilePicturePath] as String?
      : null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileController() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('currentUserId');

      if (userId == null) {
        _errorMessage = "Sesi tidak ditemukan. Silakan login kembali.";
        _userData = null;
      } else {
        _userData = await _dbHelper.getUserById(userId);
        if (_userData == null) {
          _errorMessage = "Gagal memuat data profil pengguna (ID: $userId).";
        }
      }
    } catch (e) {
      _errorMessage = "Error memuat profil: ${e.toString()}";
      _userData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    await prefs.remove('currentUsername');
    await prefs.remove('currentUserEmail');
    await prefs.remove('currentUserProfilePicPath');
    debugPrint('Sesi pengguna dihapus.');

    _userData = null;
    _isLoading = false;

    // ignore: use_build_context_synchronously
    if (!context.mounted) return;
    context.goNamed(RouteName.login);
  }
}
