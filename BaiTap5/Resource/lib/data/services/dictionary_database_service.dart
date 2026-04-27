import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DictionaryDatabaseService {
  static sqflite.Database? _db;

  static sqflite.DatabaseFactory get _databaseFactory {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }
    return sqflite.databaseFactory;
  }

  static Future<sqflite.Database> get database async {
    if (_db != null) return _db!;

    final dbPath = join(
      await _databaseFactory.getDatabasesPath(),
      'dictionary.db',
    );

    _db = await _databaseFactory.openDatabase(
      dbPath,
      options: sqflite.OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE dictionary(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL,
              meaning TEXT NOT NULL
            )
          ''');
        },
      ),
    );

    return _db!;
  }

  static Future<void> seedFromJson(Database db) async {
    final jsonString = await rootBundle.loadString('assets/dictionary.json');
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

    final batch = db.batch();
    for (final item in jsonList) {
      final map = item as Map<String, dynamic>;
      batch.insert('dictionary', {
        'word': (map['word'] as String).toLowerCase(),
        'meaning': map['meaning'] as String,
      });
    }

    await batch.commit(noResult: true);
  }
}
