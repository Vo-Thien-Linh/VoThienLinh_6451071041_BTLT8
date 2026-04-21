import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'notes.db');

    Future<Database> openNotesDatabase() {
      return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE notes(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              content TEXT
            )
          ''');
        },
      );
    }

    try {
      return await openNotesDatabase();
    } catch (_) {
      await deleteDatabase(path);
      return await openNotesDatabase();
    }
  }
}
