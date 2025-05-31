import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../data/models/article_model.dart'; // Pastikan path ini benar

class DatabaseHelper {
  static const _databaseName = "MyNewsApp.db";
  static const _databaseVersion = 4;

  // Definisi Tabel Users
  static const tableUsers = 'users';
  static const columnId = '_id';
  static const columnUsername = 'username';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnPhoneNumber = 'phone_number';
  static const columnAddress = 'address';
  static const columnCity = 'city';
  static const columnProfilePicturePath = 'profile_picture_path';

  // Definisi Tabel Bookmarks
  static const tableBookmarks = 'bookmarks';
  static const columnBUrl = 'url';
  static const columnBTitle = 'title';
  static const columnBSourceName = 'sourceName';
  static const columnBUrlToImage = 'urlToImage';
  static const columnBPublishedAt = 'publishedAt';
  static const columnBDescription = 'description';
  static const columnBAuthor = 'author';
  static const columnBContent = 'content';
  static const columnBTimestamp = 'bookmarked_at';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    print(
      "DatabaseHelper: _onCreate dijalankan, membuat tabel untuk versi $version",
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnPhoneNumber TEXT,
        $columnAddress TEXT,
        $columnCity TEXT,
        $columnProfilePicturePath TEXT
      )
    ''');
    await _createBookmarksTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
      "DatabaseHelper: _onUpgrade dijalankan, dari v$oldVersion ke v$newVersion",
    );
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      print("DatabaseHelper: Menerapkan upgrade untuk versi $i");
      switch (i) {
        case 2:
          await _createBookmarksTable(db);
          break;
        case 3:
          await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN $columnPhoneNumber TEXT',
          );
          await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN $columnAddress TEXT',
          );
          await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN $columnCity TEXT',
          );
          print(
            "DatabaseHelper: Kolom profil (phone, address, city) ditambahkan ke tabel $tableUsers untuk v3",
          );
          break;
        case 4:
          await db.execute(
            'ALTER TABLE $tableUsers ADD COLUMN $columnProfilePicturePath TEXT',
          );
          print(
            "DatabaseHelper: Kolom $columnProfilePicturePath ditambahkan ke tabel $tableUsers untuk v4",
          );
          break;
      }
    }
  }

  Future<void> _createBookmarksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableBookmarks (
        $columnBUrl TEXT PRIMARY KEY,
        $columnBTitle TEXT NOT NULL,
        $columnBSourceName TEXT,
        $columnBUrlToImage TEXT,
        $columnBPublishedAt TEXT,
        $columnBDescription TEXT,
        $columnBAuthor TEXT,
        $columnBContent TEXT,
        $columnBTimestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print("DatabaseHelper: Tabel $tableBookmarks dipastikan ada.");
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> registerUser(
    String username,
    String email,
    String password,
  ) async {
    final db = await instance.database;
    var existingUser = await db.query(
      tableUsers,
      columns: [columnId],
      where: '$columnEmail = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existingUser.isNotEmpty) {
      return {'success': false, 'message': 'Email sudah terdaftar.'};
    }
    String hashedPassword = _hashPassword(password);
    Map<String, dynamic> row = {
      columnUsername: username.trim(),
      columnEmail: email.toLowerCase().trim(),
      columnPassword: hashedPassword,
    };
    try {
      int id = await db.insert(tableUsers, row);
      return id > 0
          ? {
              'success': true,
              'message': 'Registrasi berhasil!',
              'userId': id,
              'username': username.trim(),
            }
          : {'success': false, 'message': 'Registrasi gagal.'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final db = await instance.database;
    var userQueryResult = await db.query(
      tableUsers,
      where: '$columnEmail = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (userQueryResult.isEmpty) {
      return {'success': false, 'message': 'Email tidak terdaftar.'};
    }
    Map<String, dynamic> user = userQueryResult.first;
    if (_hashPassword(password) == user[columnPassword]) {
      return {
        'success': true,
        'message': 'Login berhasil!',
        'userId': user[columnId],
        'username': user[columnUsername],
        'email': user[columnEmail],
      };
    } else {
      return {
        'success': false,
        'message': 'Password yang Anda masukkan salah.',
      };
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      columns: [
        columnId,
        columnUsername,
        columnEmail,
        columnPhoneNumber,
        columnAddress,
        columnCity,
        columnProfilePicturePath,
      ],
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<bool> updateUserProfile({
    required int userId,
    required String username,
    String? phoneNumber,
    String? address,
    String? city,
    String? profilePicturePath,
  }) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      columnUsername: username.trim(),
      columnPhoneNumber: phoneNumber?.trim(),
      columnAddress: address?.trim(),
      columnCity: city?.trim(),
      columnProfilePicturePath: profilePicturePath,
    };
    row.removeWhere((key, value) => value == null);
    if (row.isEmpty) return true;
    try {
      int count = await db.update(
        tableUsers,
        row,
        where: '$columnId = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      print("Error updating user profile: $e");
      return false;
    }
  }

  Future<bool> addBookmark(Article article) async {
    if (article.url == null || article.url!.isEmpty) {
      print("DatabaseHelper: Tidak bisa bookmark artikel tanpa URL.");
      return false;
    }
    final db = await instance.database;
    Map<String, dynamic> row = {
      columnBUrl: article.url,
      columnBTitle: article.title,
      columnBSourceName: article.sourceName,
      columnBUrlToImage: article.urlToImage,
      columnBPublishedAt: article.publishedAt?.toIso8601String(),
      columnBDescription: article.description,
      columnBAuthor: article.author,
      columnBContent: article.content,
    };
    try {
      await db.insert(
        tableBookmarks,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(
        "DatabaseHelper: Artikel '${article.title}' ditambahkan ke bookmark.",
      );
      return true;
    } catch (e) {
      print("DatabaseHelper: Error adding bookmark - $e");
      return false;
    }
  }

  Future<bool> removeBookmark(String articleUrl) async {
    final db = await instance.database;
    try {
      int count = await db.delete(
        tableBookmarks,
        where: '$columnBUrl = ?',
        whereArgs: [articleUrl],
      );
      if (count > 0) {
        print(
          "DatabaseHelper: Artikel dengan URL '$articleUrl' dihapus dari bookmark.",
        );
      } else {
        print(
          "DatabaseHelper: Tidak ada artikel dengan URL '$articleUrl' untuk dihapus dari bookmark.",
        );
      }
      return count > 0;
    } catch (e) {
      print("DatabaseHelper: Error removing bookmark - $e");
      return false;
    }
  }

  Future<bool> isBookmarked(String articleUrl) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBookmarks,
      columns: [columnBUrl],
      where: '$columnBUrl = ?',
      whereArgs: [articleUrl],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  Future<List<Article>> getAllBookmarks() async {
    final db = await instance.database;
    print("DatabaseHelper: Mengambil semua bookmarks...");
    final List<Map<String, dynamic>> maps = await db.query(
      tableBookmarks,
      orderBy: '$columnBTimestamp DESC',
    );
    print(
      "DatabaseHelper: Ditemukan ${maps.length} bookmark di DB mentah: $maps",
    );

    if (maps.isEmpty) {
      return [];
    }

    List<Article> articles = [];
    for (var map in maps) {
      try {
        articles.add(
          Article(
            url: map[columnBUrl] as String?,
            title: map[columnBTitle] as String? ?? 'Judul Tidak Ada',
            sourceName: map[columnBSourceName] as String?,
            urlToImage: map[columnBUrlToImage] as String?,
            publishedAt: map[columnBPublishedAt] != null
                ? DateTime.tryParse(map[columnBPublishedAt] as String)
                : null,
            description: map[columnBDescription] as String?,
            author: map[columnBAuthor] as String?,
            content: map[columnBContent] as String?,
          ),
        );
      } catch (e) {
        print("DatabaseHelper: Error mapping bookmark - Data: $map, Error: $e");
      }
    }
    print(
      "DatabaseHelper: Berhasil map ${articles.length} bookmark menjadi objek Article.",
    );
    return articles;
  }

  Future<bool> verifyOldPassword(int userId, String oldPassword) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> users = await db.query(
      tableUsers,
      columns: [columnPassword],
      where: '$columnId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (users.isNotEmpty) {
      final String storedHashedPassword = users.first[columnPassword] as String;
      final String inputHashedOldPassword = _hashPassword(oldPassword);
      return inputHashedOldPassword == storedHashedPassword;
    }
    return false;
  }

  Future<bool> updateUserPassword(int userId, String newPassword) async {
    final db = await instance.database;
    final String newHashedPassword = _hashPassword(newPassword);

    try {
      int count = await db.update(
        tableUsers,
        {columnPassword: newHashedPassword},
        where: '$columnId = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      print("Error updating user password: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      columns: [
        columnId,
        columnUsername,
        columnEmail,
        columnPhoneNumber,
        columnAddress,
        columnCity,
        columnProfilePicturePath,
      ],
      where: '$columnEmail = ?',
      whereArgs: [email.toLowerCase().trim()],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<bool> updatePasswordByEmail(String email, String newPassword) async {
    final db = await instance.database;

    Map<String, dynamic>? user = await getUserByEmail(email);
    if (user == null || user[columnId] == null) {
      print("DatabaseHelper: Email tidak ditemukan untuk update password.");
      return false;
    }

    final String newHashedPassword = _hashPassword(newPassword);
    try {
      int count = await db.update(
        tableUsers,
        {columnPassword: newHashedPassword},
        where: '$columnEmail = ?',
        whereArgs: [email.toLowerCase().trim()],
      );
      return count > 0;
    } catch (e) {
      print("Error updating password by email: $e");
      return false;
    }
  }
}
