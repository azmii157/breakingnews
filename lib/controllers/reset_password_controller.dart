import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class ResetPasswordController with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  bool _isNewPasswordVisible = false;
  bool get isNewPasswordVisible => _isNewPasswordVisible;

  bool _isConfirmNewPasswordVisible = false;
  bool get isConfirmNewPasswordVisible => _isConfirmNewPasswordVisible;

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmNewPasswordVisibility() {
    _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      bool updateSuccess = await _dbHelper.updatePasswordByEmail(
        email,
        newPasswordController.text,
      );

      if (updateSuccess) {
        _successMessage =
            "Password berhasil direset! Silakan login dengan password baru Anda.";
        newPasswordController.clear();
        confirmNewPasswordController.clear();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            "Gagal mereset password. Email mungkin tidak valid atau terjadi kesalahan server.";
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
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }
}
