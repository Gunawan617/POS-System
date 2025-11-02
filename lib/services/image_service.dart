import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      // For web, return the path directly (it's a blob URL)
      if (kIsWeb) {
        return image.path;
      }

      // For mobile/desktop, save to app directory
      final String savedPath = await _saveImage(image.path);
      return savedPath;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String> _saveImage(String imagePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesDir = '${appDir.path}/product_images';
    
    // Create directory if not exists
    final Directory imageDirectory = Directory(imagesDir);
    if (!await imageDirectory.exists()) {
      await imageDirectory.create(recursive: true);
    }

    // Generate unique filename
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imagePath)}';
    final String newPath = '$imagesDir/$fileName';

    // Copy file
    final File sourceFile = File(imagePath);
    await sourceFile.copy(newPath);

    return newPath;
  }

  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    if (kIsWeb) return; // Can't delete blob URLs on web

    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  bool isValidImagePath(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return false;
    if (kIsWeb) return true; // Assume web paths are valid
    
    final File file = File(imagePath);
    return file.existsSync();
  }
}

