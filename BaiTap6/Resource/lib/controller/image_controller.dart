import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../data/models/image_model.dart';
import '../data/repository/image_repository.dart';

class ImageController extends ChangeNotifier {
  final ImageRepository _repository = ImageRepository();

  List<ImageModel> _images = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ImageModel> get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize - load all images from database
  Future<void> initialize() async {
    await loadImages();
  }

  /// Load all images from database
  Future<void> loadImages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _images = await _repository.getAllImages();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new image with byte data
  Future<void> addImage(Uint8List imageBytes, String fileName) async {
    try {
      final newImage = await _repository.addImage(imageBytes, fileName);
      _images.insert(0, newImage);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Add a sample image (for demo/testing)
  Future<void> addSampleImage(String fileName) async {
    try {
      final newImage = await _repository.addSampleImage(fileName);
      _images.insert(0, newImage);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete image by id
  Future<void> deleteImage(int id) async {
    try {
      final success = await _repository.deleteImage(id);
      if (success) {
        _images.removeWhere((img) => img.id == id);
        _errorMessage = null;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Delete all images
  Future<void> deleteAllImages() async {
    try {
      await _repository.deleteAllImages();
      _images.clear();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get image count
  int getImageCount() => _images.length;

  /// Get image by index
  ImageModel? getImageAt(int index) {
    if (index >= 0 && index < _images.length) {
      return _images[index];
    }
    return null;
  }
}
