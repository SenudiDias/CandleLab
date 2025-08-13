import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<File?> pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Copy the temporary file to a persistent location
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');
      return savedFile;
    }
    return null;
  }

  static Future<void> deleteImage(String url) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print('Failed to delete image: $e');
      rethrow;
    }
  }

  static Future<List<String>> uploadImages(
    List<File> images,
    String path, {
    Function(int, int)? onProgress,
  }) async {
    final List<String> urls = [];
    final Set<String> uploadedFiles = {};

    for (int i = 0; i < images.length; i++) {
      final file = images[i];

      try {
        // Skip if file doesn't exist or already uploaded
        if (!(await file.exists())) {
          print('File not found: ${file.path}');
          continue;
        }
        if (uploadedFiles.contains(file.path)) {
          print('File already uploaded: ${file.path}');
          continue;
        }

        // Create unique filename
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = FirebaseStorage.instance.ref().child('$path/$fileName');

        // Upload file
        try {
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          final url = await snapshot.ref.getDownloadURL();
          urls.add(url);
          uploadedFiles.add(file.path);

          // Delete local file only if it still exists
          try {
            if (await file.exists()) {
              await file.delete();
              print('Deleted local file: ${file.path}');
            }
          } catch (e) {
            print('Failed to delete local file: $e');
          }

          if (onProgress != null) onProgress(i + 1, images.length);
        } catch (e) {
          print('Upload failed for ${file.path}: $e');
          continue;
        }
      } catch (e) {
        print('Error processing file ${file.path}: $e');
        continue;
      }
    }

    return urls;
  }
}
