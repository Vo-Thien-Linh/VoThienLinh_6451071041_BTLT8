import '../models/category_models.dart';
import '../services/database_service.dart';

class CategoryRepository {
  Future<int> insert(Category category) async {
    final db = await DatabaseService.database;
    return db.insert('categories', category.toMap());
  }

  Future<List<Category>> getAll() async {
    final db = await DatabaseService.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((e) => Category.fromMap(e)).toList();
  }
}
