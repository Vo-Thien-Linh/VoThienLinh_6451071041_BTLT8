import '../data/models/task_models.dart';
import '../data/repository/task_repository.dart';
import '../data/services/file_service.dart';

class TaskController {
  final repo = TaskRepository();

  Future<List<Task>> getTasks() => repo.getAll();

  Future<void> addTask(String title) async {
    await repo.insert(Task(title: title, isDone: false));
  }

  Future<void> toggle(Task task) async {
    await repo.update(
      Task(id: task.id, title: task.title, isDone: !task.isDone),
    );
  }

  Future<void> delete(int id) async {
    await repo.delete(id);
  }

  Future<String> exportTasksToJson() async {
    final tasks = await repo.getAll();
    return FileService.exportTasks(tasks);
  }

  Future<int> importTasksFromJson() async {
    final tasks = await FileService.importTasks();
    await repo.replaceAll(tasks);
    return tasks.length;
  }
}
