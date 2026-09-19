import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/material.dart';
import '../models/settings_data.dart';

class ImageCompilationService {

  /// Captures the dashboard widget and composites it onto the camera image.
  /// Then saves the final composite to the device gallery.
  static Future<bool> burnAndSave({
    required GlobalKey dashboardKey,
    required Uint8List cameraImageBytes,
    required SettingsData settings,
  }) async {
    try {
      debugPrint('Starting image compilation...');
      final bgImage = img.decodeImage(cameraImageBytes);
      if (bgImage == null) return false;

      img.Image finalImage = bgImage;

      if (settings.geoTagEnabled) {
        final boundary = dashboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        
        if (boundary != null && boundary.size.width > 0 && boundary.size.height > 0) {
          final ui.Image overlayUiImage = await boundary.toImage(pixelRatio: 2.0);
          final ByteData? byteData = await overlayUiImage.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final Uint8List overlayBytes = byteData.buffer.asUint8List();
            final overlayImage = img.decodeImage(overlayBytes);
            
            if (overlayImage != null) {
              final targetWidth = (bgImage.width * 0.95).toInt();
              final resizedOverlay = img.copyResize(overlayImage, width: targetWidth);
              
              final dstX = (bgImage.width - targetWidth) ~/ 2;
              
              int dstY;
              if (settings.geoTagPlacement == GeoTagPlacement.bottom) {
                final bottomMargin = (bgImage.height * 0.03).toInt();
                dstY = bgImage.height - resizedOverlay.height - bottomMargin;
              } else {
                final topMargin = (bgImage.height * 0.03).toInt();
                dstY = topMargin;
              }

              img.compositeImage(bgImage, resizedOverlay, dstX: dstX, dstY: dstY);
              finalImage = bgImage;
            }
          }
        }
      }

      final finalBytes = img.encodeJpg(finalImage, quality: 92);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(finalBytes),
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
