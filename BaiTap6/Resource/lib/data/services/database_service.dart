import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/image_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'images.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Insert a new image
  Future<int> insertImage(ImageModel image) async {
    final db = await database;
    return await db.insert(
      'images',
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all images
  Future<List<ImageModel>> getAllImages() async {
    final db = await database;
    final maps = await db.query('images', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => ImageModel.fromMap(maps[i]));
  }

  /// Get image by id
  Future<ImageModel?> getImageById(int id) async {
    final db = await database;
    final maps = await db.query('images', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ImageModel.fromMap(maps.first);
    }
    return null;
  }

  /// Update image
  Future<int> updateImage(ImageModel image) async {
    final db = await database;
    return await db.update(
      'images',
      image.toMap(),
      where: 'id = ?',
      whereArgs: [image.id],
    );
  }

  /// Delete image
  Future<int> deleteImage(int id) async {
    final db = await database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all images
  Future<int> deleteAllImages() async {
    final db = await database;
    return await db.delete('images');
  }

  /// Close database
  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
