import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';

class ChangePasswordController with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool _isOldPasswordVisible = false;
  bool get isOldPasswordVisible => _isOldPasswordVisible;

  bool _isNewPasswordVisible = false;
  bool get isNewPasswordVisible => _isNewPasswordVisible;

  bool _isConfirmNewPasswordVisible = false;
  bool get isConfirmNewPasswordVisible => _isConfirmNewPasswordVisible;

  void toggleOldPasswordVisibility() {
    _isOldPasswordVisible = !_isOldPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
    notifyListeners();
  }

  Future<bool> changePassword() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('currentUserId');

      if (userId == null) {
        _errorMessage = "Sesi pengguna tidak ditemukan. Silakan login kembali.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool oldPasswordCorrect = await _dbHelper.verifyOldPassword(
        userId,
        oldPasswordController.text,
      );
      if (!oldPasswordCorrect) {
        _errorMessage = "Password lama yang Anda masukkan salah.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool updateSuccess = await _dbHelper.updateUserPassword(
        userId,
        newPasswordController.text,
      );

      if (updateSuccess) {
        _successMessage = "Password berhasil diubah!";
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            "Gagal mengubah password di database. Silakan coba lagi.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
