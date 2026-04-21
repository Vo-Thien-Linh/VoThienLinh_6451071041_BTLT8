import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/task_models.dart';

class FileService {
  static const _fileName = 'tasks_backup.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<String> exportTasks(List<Task> tasks) async {
    final file = await _getFile();
    final jsonList = tasks.map((task) => task.toJson()).toList();

    await file.writeAsString(jsonEncode(jsonList), flush: true);

    return file.path;
  }

  static Future<List<Task>> importTasks() async {
    final file = await _getFile();

    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final decoded = jsonDecode(content);

    if (decoded is! List) {
      throw const FormatException('Invalid JSON format for tasks backup.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Task.fromJson)
        .toList();
  }
}
