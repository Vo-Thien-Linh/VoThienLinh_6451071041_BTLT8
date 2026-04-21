import '../models/task_models.dart';
import '../services/database_service.dart';

class TaskRepository {
  Future<int> insert(Task task) async {
    final db = await DatabaseService.database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAll() async {
    final db = await DatabaseService.database;
    final result = await db.query('tasks');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> update(Task task) async {
    final db = await DatabaseService.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await DatabaseService.database;
    await db.delete('tasks');
  }

  Future<void> replaceAll(List<Task> tasks) async {
    final db = await DatabaseService.database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      for (final task in tasks) {
        await txn.insert(
          'tasks',
          Task(title: task.title, isDone: task.isDone).toMap(),
        );
      }
    });
  }
}
