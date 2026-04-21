import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseRepository {
  Future<List<Expense>> getAll() async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT expenses.*, categories.name as categoryName
      FROM expenses
      JOIN categories ON expenses.categoryId = categories.id
      ORDER BY expenses.id DESC
    ''');

    return result.map((e) => Expense.fromMap(e)).toList();
  }

  Future<void> insert(Expense e) async {
    final db = await DatabaseService.database;
    await db.insert('expenses', e.toMap());
  }

  Future<void> update(Expense e) async {
    final db = await DatabaseService.database;
    await db.update('expenses', e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // 👉 tổng theo category
  Future<List<Map<String, dynamic>>> sumByCategory() async {
    final db = await DatabaseService.database;

    return db.rawQuery('''
      SELECT categories.name, SUM(amount) as total
      FROM expenses
      JOIN categories ON expenses.categoryId = categories.id
      GROUP BY categoryId
    ''');
  }
}