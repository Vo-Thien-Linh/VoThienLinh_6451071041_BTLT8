import '../models/category_models.dart';
import '../services/database_service.dart';

class CategoryRepository {
  Future<List<Category>> getAll() async {
    final db = await DatabaseService.database;
    final result = await db.query('categories');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<void> insert(Category c) async {
    final db = await DatabaseService.database;
    await db.insert('categories', c.toMap());
  }
}
