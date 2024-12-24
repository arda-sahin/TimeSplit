import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton örneği
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Veritabanına erişim sağlayan getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('categories.db');
    return _database!;
  }

  // Veritabanının path'ini belirleyip açıyor
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // İlk kurulumda tabloyu (tabloları) oluşturuyor
  Future _createDB(Database db, int version) async {
    const categoryTable = '''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      isProductive INTEGER NOT NULL
    )
    ''';

    // Şimdilik sadece categories tablosu var
    // (timer_entries tablo oluşturma kodu ayrı TimerService.createTable() içinde)
    await db.execute(categoryTable);
  }

  // Veritabanını kapatma işlemi
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
