// lib/controllers/edit_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../services/database_helper.dart';

class EditProfileController with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  String? _currentProfileImagePathFromDb;
  String? get currentProfileImagePathFromDb => _currentProfileImagePathFromDb;

  String? _newlySavedImagePath;

  EditProfileController({required int userId}) {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    cityController = TextEditingController();
    loadUserProfile(userId);
  }

  Future<void> loadUserProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedImageFile = null;
    _newlySavedImagePath = null;

    try {
      Map<String, dynamic>? userData = await _dbHelper.getUserById(userId);
      if (userData != null) {
        usernameController.text = userData[DatabaseHelper.columnUsername] ?? '';
        emailController.text = userData[DatabaseHelper.columnEmail] ?? '';
        phoneController.text = userData[DatabaseHelper.columnPhoneNumber] ?? '';
        addressController.text = userData[DatabaseHelper.columnAddress] ?? '';
        cityController.text = userData[DatabaseHelper.columnCity] ?? '';
        _currentProfileImagePathFromDb =
            userData[DatabaseHelper.columnProfilePicturePath];
      } else {
        _errorMessage = "Gagal memuat data profil untuk diedit.";
      }
    } catch (e) {
      _errorMessage = "Error: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileExtension = p.extension(pickedFile.path);
        final String uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final String newPath = p.join(appDir.path, uniqueFileName);

        final File imageFile = File(pickedFile.path);
        await imageFile.copy(newPath);

        _selectedImageFile = File(newPath);
        _newlySavedImagePath = newPath;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Gagal memilih gambar: ${e.toString()}";
      notifyListeners();
      print("Error picking image: $e");
    }
  }

  void removeProfileImage() {
    _selectedImageFile = null;
    _newlySavedImagePath = "";
    notifyListeners();
  }

  Future<Map<String, dynamic>> saveProfileChanges(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String? finalProfilePicturePath;
    if (_newlySavedImagePath != null) {
      if (_newlySavedImagePath == "") {
        finalProfilePicturePath = null;
      } else {
        finalProfilePicturePath = _newlySavedImagePath;
      }
    } else {
      finalProfilePicturePath = _currentProfileImagePathFromDb;
    }

    try {
      bool success = await _dbHelper.updateUserProfile(
        userId: userId,
        username: usernameController.text,
        phoneNumber: phoneController.text.isNotEmpty
            ? phoneController.text
            : null,
        address: addressController.text.isNotEmpty
            ? addressController.text
            : null,
        city: cityController.text.isNotEmpty ? cityController.text : null,
        profilePicturePath: finalProfilePicturePath,
      );

      if (success) {
        _currentProfileImagePathFromDb = finalProfilePicturePath;
        _selectedImageFile = null;
        _newlySavedImagePath = null;
        return {'success': true, 'message': 'Profil berhasil diperbarui!'};
      } else {
        _errorMessage = "Gagal menyimpan perubahan profil ke database.";
        return {'success': false, 'message': _errorMessage!};
      }
    } catch (e) {
      _errorMessage = "Error menyimpan profil: ${e.toString()}";
      return {'success': false, 'message': _errorMessage!};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
