import 'dart:typed_data';
import '../models/image_model.dart';
import '../services/database_service.dart';
import '../services/file_storage_service.dart';

class ImageRepository {
  final DatabaseService _databaseService = DatabaseService();
  final FileStorageService _fileStorageService = FileStorageService();

  /// Add a new image (save file + store path in database)
  Future<ImageModel> addImage(Uint8List imageBytes, String fileName) async {
    try {
      // Save image file
      final filePath = await _fileStorageService.saveImage(
        imageBytes,
        fileName,
      );

      // Create model
      final imageModel = ImageModel(path: filePath, createdAt: DateTime.now());

      // Save to database
      final id = await _databaseService.insertImage(imageModel);

      // Return model with id
      return imageModel.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to add image: $e');
    }
  }

  /// Add a sample image (for testing)
  Future<ImageModel> addSampleImage(String fileName) async {
    try {
      // Save sample image file
      final filePath = await _fileStorageService.saveSampleImage(fileName);

      // Create model
      final imageModel = ImageModel(path: filePath, createdAt: DateTime.now());

      // Save to database
      final id = await _databaseService.insertImage(imageModel);

      // Return model with id
      return imageModel.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to add sample image: $e');
    }
  }

  /// Get all images
  Future<List<ImageModel>> getAllImages() async {
    try {
      return await _databaseService.getAllImages();
    } catch (e) {
      throw Exception('Failed to get images: $e');
    }
  }

  /// Get image by id
  Future<ImageModel?> getImageById(int id) async {
    try {
      return await _databaseService.getImageById(id);
    } catch (e) {
      throw Exception('Failed to get image: $e');
    }
  }

  /// Delete image (delete file + remove from database)
  Future<bool> deleteImage(int id) async {
    try {
      final image = await _databaseService.getImageById(id);
      if (image != null) {
        // Delete file
        await _fileStorageService.deleteImage(image.path);

        // Delete from database
        await _databaseService.deleteImage(id);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete all images
  Future<void> deleteAllImages() async {
    try {
      final images = await _databaseService.getAllImages();
      for (final image in images) {
        await _fileStorageService.deleteImage(image.path);
      }
      await _databaseService.deleteAllImages();
    } catch (e) {
      throw Exception('Failed to delete all images: $e');
    }
  }

  /// Load image file for display
  Future<Uint8List?> loadImageFile(String filePath) async {
    try {
      return await _fileStorageService.loadImage(filePath);
    } catch (e) {
      throw Exception('Failed to load image file: $e');
    }
  }
}
