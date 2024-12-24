import 'database_helper.dart';
import '../models/timer_entry.dart';

class TimerService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> createTable() async {
    final db = await _dbHelper.database;
    await db.execute('''
      CREATE TABLE timer_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryName TEXT NOT NULL,
        durationInSeconds INTEGER NOT NULL,
        isProductive INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> addTimerEntry(TimerEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert('timer_entries', entry.toMap());
  }

  Future<List<TimerEntry>> getTimerEntries() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('timer_entries');
    return maps.map((map) => TimerEntry.fromMap(map)).toList();
  }
}
