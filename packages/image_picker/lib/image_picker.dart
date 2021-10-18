library image_picker;

import 'dart:async';

import 'package:flutter/services.dart';

class ImagePicker {
  static const _channel = MethodChannel('rhythm_native/image_picker');

  static Future<List<PickedFile>?> pick({
    int count = 1,
    PickType pickType = PickType.image,
    bool allowSelectOriginal = false,
    bool gif = true,
    CropOption? cropOpt,
    int? maxSize,
    double? quality,
  }) async {
    assert(count > 0, 'count must > 0');

    if (quality != null) {
      assert(quality > 0, 'quality must > 0');
      assert(quality <= 1, 'quality must <= 1');
    }

    if (maxSize != null) {
      assert(maxSize > 0, 'maxSize must > 0');
    }

    try {
      final res = await _channel.invokeMethod<List>('pick', {
        'count': count,
        'pickType': pickType.toString(),
        'allowSelectOriginal': allowSelectOriginal,
        'gif': gif,
        'maxSize': maxSize,
        'quality': quality ?? -1,
        'cropOption': cropOpt != null
            ? {
                'quality': quality ?? 1,
                'cropType': cropOpt.cropType.toString(),
                if (cropOpt.aspectRatio != null) ...{
                  'aspectRatioX': cropOpt.aspectRatio?.aspectRatioX,
                  'aspectRatioY': cropOpt.aspectRatio?.aspectRatioY,
                },
              }
            : null,
      });

      if (res != null) {
        return res.map((image) {
          return PickedFile(
            thumbPath: image['thumbPath'],
            path: image['path'],
            size: image['size'] != null
                ? (image['size'] / 1024).toDouble()
                : null,
          );
        }).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<PickedFile>?> openCamera({
    PickType pickType = PickType.image,
    int maxTime = 15,
    CropOption? cropOpt,
    int? maxSize,
    double? quality,
  }) async {
    if (quality != null) {
      assert(quality > 0, 'quality must > 0');
      assert(quality <= 1, 'quality must <= 1');
    }

    if (maxSize != null) {
      assert(maxSize > 0, 'maxSize must > 0');
    }

    try {
      final res = await _channel.invokeMethod<List>('openCamera', {
        'pickType': pickType.toString(),
        'maxTime': maxTime,
        'maxSize': maxSize,
        'quality': quality ?? -1,
        'cropOption': cropOpt != null
            ? {
                'quality': quality ?? 1,
                'cropType': cropOpt.cropType.toString(),
                if (cropOpt.aspectRatio != null) ...{
                  'aspectRatioX': cropOpt.aspectRatio?.aspectRatioX,
                  'aspectRatioY': cropOpt.aspectRatio?.aspectRatioY,
                },
              }
            : null,
      });

      if (res != null) {
        return res.map((image) {
          return PickedFile(
            thumbPath: image['thumbPath'],
            path: image['path'],
            size: image['size'] != null
                ? (image['size'] / 1024).toDouble()
                : null,
          );
        }).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

enum PickType { image, video, all }
enum CropType { rect, circle }

class CropAspectRatio {
  final int aspectRatioX;
  final int aspectRatioY;

  const CropAspectRatio(this.aspectRatioX, this.aspectRatioY)
      : assert(aspectRatioX > 0, 'aspectRatioX must > 0'),
        assert(aspectRatioY > 0, 'aspectRatioY must > 0');

  static const wh2x1 = CropAspectRatio(2, 1);
  static const wh1x2 = CropAspectRatio(1, 2);
  static const wh3x4 = CropAspectRatio(3, 4);
  static const wh4x3 = CropAspectRatio(4, 3);
  static const wh16x9 = CropAspectRatio(16, 9);
  static const wh9x16 = CropAspectRatio(9, 16);
}

class CropOption {
  final CropType cropType;
  final CropAspectRatio? aspectRatio;

  const CropOption({
    this.aspectRatio,
    this.cropType = CropType.rect,
  });
}

class PickedFile {
  /// Video thumbnail image path
  final String? thumbPath;

  /// Video path or image path
  final String path;

  /// File size
  final double? size;

  const PickedFile({
    required this.path,
    this.thumbPath,
    this.size,
  });
}
