import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class ImageGallerySaver {
  static const _channel = MethodChannel('rhythm_native/image_gallery_saver');

  /// save image to Gallery
  /// imageBytes can't null
  /// return Map type
  /// for example: {"isSuccess": true, "filePath": String?}
  static Future<Map<String, dynamic>> saveImage(
    Uint8List imageBytes, {
    int quality = 80,
    String? name,
    bool isReturnImagePathOfIOS = false,
  }) async {
    final result = await _channel.invokeMethod<Map>(
      'saveImageToGallery',
      <String, dynamic>{
        'imageBytes': imageBytes,
        'quality': quality,
        'name': name,
        'isReturnImagePathOfIOS': isReturnImagePathOfIOS
      },
    );

    return result!.cast<String, dynamic>();
  }

  /// Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery.
  static Future<Map<String, dynamic>> saveFile(
    String file, {
    bool isReturnPathOfIOS = false,
  }) async {
    final result = await _channel.invokeMethod<Map>(
      'saveFileToGallery',
      <String, dynamic>{'file': file, 'isReturnPathOfIOS': isReturnPathOfIOS},
    );

    return result!.cast<String, dynamic>();
  }
}
