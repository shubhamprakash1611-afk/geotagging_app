import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/material.dart';
import '../models/settings_data.dart';

class ImageCompilationService {

  /// GPU-accelerated compositing using dart:ui Canvas.
  /// No pure-Dart image decoding — uses native platform codecs.
  static Future<bool> burnAndSaveWithUiImage({
    required Uint8List cameraImageBytes,
    ui.Image? overlayUiImage,
    required SettingsData settings,
  }) async {
    try {
      // Step 1: Decode camera JPEG using native platform codec (~100ms vs ~10s pure Dart)
      final codec = await ui.instantiateImageCodec(cameraImageBytes);
      final frame = await codec.getNextFrame();
      final cameraImage = frame.image;

      ui.Image finalImage;

      if (overlayUiImage != null && settings.geoTagEnabled) {
        // Step 2: Composite using GPU-accelerated Canvas (~10ms vs ~3s pure Dart)
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // Draw camera image
        canvas.drawImage(cameraImage, Offset.zero, Paint());

        // Calculate overlay placement
        final targetWidth = cameraImage.width * 0.95;
        final scale = targetWidth / overlayUiImage.width;
        final scaledHeight = overlayUiImage.height * scale;
        final dstX = (cameraImage.width - targetWidth) / 2;

        double dstY;
        if (settings.geoTagPlacement == GeoTagPlacement.top) {
          dstY = cameraImage.height * 0.03;
        } else {
          dstY = cameraImage.height - scaledHeight - (cameraImage.height * 0.03);
        }

        // Draw overlay scaled and positioned
        canvas.save();
        canvas.translate(dstX, dstY);
        canvas.scale(scale);
        canvas.drawImage(overlayUiImage, Offset.zero, Paint());
        canvas.restore();

        final picture = recorder.endRecording();
        finalImage = await picture.toImage(cameraImage.width, cameraImage.height);
      } else {
        finalImage = cameraImage;
      }

      // Step 3: Encode to PNG using native codec (~500ms vs ~5s pure Dart JPEG)
      final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;
      final finalBytes = byteData.buffer.asUint8List();

      // Step 4: Save to gallery
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final result = await ImageGallerySaverPlus.saveImage(
        finalBytes,
        name: 'GeoTag_$timestamp',
        quality: 100,
        isReturnImagePathOfIOS: true,
      );

      return result['isSuccess'] == true;
    } catch (e) {
      debugPrint('Image compilation failed: $e');
      return false;
    }
  }
}

