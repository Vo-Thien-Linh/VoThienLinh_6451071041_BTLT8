import 'package:flutter/material.dart';
import '../controller/task_controller.dart';
import '../data/models/task_models.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final controller = TaskController();
  final titleController = TextEditingController();

  List<Task> tasks = [];

  Future<void> loadTasks() async {
    final loadedTasks = await controller.getTasks();
    if (!mounted) return;
    setState(() {
      tasks = loadedTasks;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> addTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;

    await controller.addTask(title);
    titleController.clear();
    await loadTasks();
  }

  Future<void> exportTasks() async {
    final path = await controller.exportTasksToJson();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Da export JSON: $path')));
  }

  Future<void> importTasks() async {
    try {
      final count = await controller.importTasksFromJson();
      await loadTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Da import $count task tu JSON')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import that bai: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-do List - 6451071041')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addTask, child: const Text('Them')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: exportTasks,
                    child: const Text('Export JSON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: importTasks,
                    child: const Text('Import JSON'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Chua co task nao'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return CheckboxListTile(
                          value: task.isDone,
                          title: Text(task.title),
                          onChanged: (_) async {
                            await controller.toggle(task);
                            await loadTasks();
                          },
                          secondary: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (task.id != null) {
                                await controller.delete(task.id!);
                                await loadTasks();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
