import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/image_controller.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late ImageController _imageController;

  @override
  void initState() {
    super.initState();
    _imageController = ImageController();
    _imageController.initialize();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImageController>(
      create: (_) => _imageController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Image Gallery - 6451071041'),
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          actions: [
            Consumer<ImageController>(
              builder: (context, controller, _) {
                return controller.images.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: _confirmDeleteAll,
                        tooltip: 'Delete all images',
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addSampleImages,
          backgroundColor: Colors.deepPurple,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Image'),
        ),
        body: Consumer<ImageController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  'Error: ${controller.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (controller.images.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No images yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to add images',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: controller.images.length,
              itemBuilder: (context, index) {
                final image = controller.images[index];
                return _buildImageTile(context, image, controller);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageTile(
    BuildContext context,
    dynamic image,
    ImageController controller,
  ) {
    return GestureDetector(
      onLongPress: () => _showImageOptions(context, image, controller),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.deepPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _buildImageWidget(image.path),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _deleteImage(context, image, controller),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String filePath) {
    final file = File(filePath);

    if (!file.existsSync()) {
      return Container(
        color: Colors.grey[300],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'File not found',
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Error loading',
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageOptions(
    BuildContext context,
    dynamic image,
    ImageController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Image Info'),
              onTap: () {
                Navigator.pop(context);
                _showImageInfo(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteImage(context, image, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageInfo(BuildContext context, dynamic image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID', image.id.toString()),
              const SizedBox(height: 8),
              _buildInfoRow('Path', image.path),
              const SizedBox(height: 8),
              _buildInfoRow('Created', image.createdAt.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _deleteImage(
    BuildContext context,
    dynamic image,
    ImageController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteImage(image.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Image deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Images'),
        content: const Text('Are you sure you want to delete all images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _imageController.deleteAllImages();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All images deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addSampleImages() {
    _imageController.addSampleImage(
      'sample_${DateTime.now().millisecondsSinceEpoch}.bin',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image added successfully')));
  }
}
