import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Yeni kullanıcı ekle
  Future<bool> registerUser(String username, String password) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'users',
        {
          'username': username,
          'password': password,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
        // Eğer aynı username varsa hata fırlatır
      );
      return true; // başarılı kayıt
    } catch (e) {
      // "username already in use" vb. hata
      return false;
    }
  }

  // Kullanıcı girişi: doğruysa true döner, yanlışsa false
  Future<bool> loginUser(String username, String password) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return true; // bulundu
    } else {
      return false; // yok veya şifre hatalı
    }
  }
}
