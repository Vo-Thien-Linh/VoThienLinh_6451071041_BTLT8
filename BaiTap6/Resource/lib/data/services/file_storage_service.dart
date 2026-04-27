import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() {
    return _instance;
  }

  FileStorageService._internal();

  /// Get application documents directory for images
  Future<Directory> _getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/images');
    if (!imageDir.existsSync()) {
      imageDir.createSync(recursive: true);
    }
    return imageDir;
  }

  /// Save image with byte data
  /// Returns the file path where image was saved
  Future<String> saveImage(Uint8List imageBytes, String fileName) async {
    try {
      final imageDir = await _getImageDirectory();
      final file = File('${imageDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save image: $e');
    }
  }

  /// Create a sample image file (for testing)
  /// Generates a simple colored image as bytes
  Future<String> saveSampleImage(String fileName) async {
    try {
      // Generate a simple 100x100 blue PNG-like byte data (simplified)
      final imageBytes = Uint8List.fromList([
        // This is a simplified placeholder - in real app, use image package
        ...List.generate(10000, (i) => i % 256),
      ]);
      return await saveImage(imageBytes, fileName);
    } catch (e) {
      throw Exception('Failed to save sample image: $e');
    }
  }

  /// Load image from file path
  Future<Uint8List?> loadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  /// Delete image file
  Future<bool> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Check if image file exists
  Future<bool> imageExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      throw Exception('Failed to check image existence: $e');
    }
  }

  /// Get list of all saved images
  Future<List<String>> getAllSavedImagePaths() async {
    try {
      final imageDir = await _getImageDirectory();
      final files = imageDir.listSync();
      return files.whereType<File>().map((f) => f.path).toList();
    } catch (e) {
      throw Exception('Failed to get image paths: $e');
    }
  }
}
