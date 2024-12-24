import 'database_helper.dart';
import '../models/category.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }
}
