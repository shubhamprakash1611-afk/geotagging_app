import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../models/settings_data.dart';

class ImageCompilationService {
  static const MethodChannel _androidCompositor =
      MethodChannel('com.geotagging.app/image_compositor');

  /// Burns the rendered GeoTag overlay into the captured photo and publishes
  /// the finished JPEG to the gallery.
  ///
  /// Android uses a bounded native worker pool so decoding, compositing and
  /// JPEG compression never block Flutter's UI isolate. Other platforms keep
  /// the existing dart:ui fallback.
  static Future<bool> burnAndSave({
    required String cameraImagePath,
    ui.Image? overlayUiImage,
    required SettingsData settings,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final overlayBytes = await _encodeOverlay(overlayUiImage, settings);

      if (Platform.isAndroid) {
        final response =
            await _androidCompositor.invokeMapMethod<String, dynamic>(
          'saveComposite',
          {
            'cameraPath': cameraImagePath,
            'overlayBytes': overlayBytes,
            'placement': settings.geoTagPlacement.name,
            'directory': settings.saveDirectory,
            'jpegQuality': 94,
          },
        );

        final success = response?['success'] == true;
        final nativeMs = response?['elapsedMs'];
        debugPrint(
          'Gallery save ${success ? 'completed' : 'failed'} '
          'in ${stopwatch.elapsedMilliseconds}ms '
          '(native: ${nativeMs ?? 'unknown'}ms)',
        );
        return success;
      }

      return await _burnAndSaveFallback(
        cameraImagePath: cameraImagePath,
        overlayBytes: overlayBytes,
        settings: settings,
      );
    } catch (error, stackTrace) {
      debugPrint('Image compilation failed: $error\n$stackTrace');
      return false;
    } finally {
      overlayUiImage?.dispose();
    }
  }

  static Future<Uint8List?> _encodeOverlay(
    ui.Image? overlayUiImage,
    SettingsData settings,
  ) async {
    if (!settings.geoTagEnabled || overlayUiImage == null) {
      return null;
    }

    final byteData =
        await overlayUiImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Portable fallback retained for iOS. Android deliberately bypasses this
  /// full-resolution PNG path because it was the source of the gallery delay.
  static Future<bool> _burnAndSaveFallback({
    required String cameraImagePath,
    Uint8List? overlayBytes,
    required SettingsData settings,
  }) async {
    final cameraBytes = await File(cameraImagePath).readAsBytes();
    final cameraCodec = await ui.instantiateImageCodec(cameraBytes);
    final cameraFrame = await cameraCodec.getNextFrame();
    final cameraImage = cameraFrame.image;

    ui.Image? overlayImage;
    ui.Image finalImage = cameraImage;

    try {
      if (overlayBytes != null && settings.geoTagEnabled) {
        final overlayCodec = await ui.instantiateImageCodec(overlayBytes);
        final overlayFrame = await overlayCodec.getNextFrame();
        overlayImage = overlayFrame.image;

        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawImage(cameraImage, ui.Offset.zero, ui.Paint());

        final targetWidth = cameraImage.width * 0.95;
        final scale = targetWidth / overlayImage.width;
        final scaledHeight = overlayImage.height * scale;
        final destinationX = (cameraImage.width - targetWidth) / 2;
        final destinationY = settings.geoTagPlacement == GeoTagPlacement.top
            ? cameraImage.height * 0.03
            : cameraImage.height - scaledHeight - (cameraImage.height * 0.03);

        canvas
          ..save()
          ..translate(destinationX, destinationY)
          ..scale(scale)
          ..drawImage(overlayImage, ui.Offset.zero, ui.Paint())
          ..restore();

        final picture = recorder.endRecording();
        finalImage =
            await picture.toImage(cameraImage.width, cameraImage.height);
        picture.dispose();
      }

      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final result = await ImageGallerySaverPlus.saveImage(
        byteData.buffer.asUint8List(),
        name: 'GeoTag_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
        isReturnImagePathOfIOS: true,
      );
      return result['isSuccess'] == true;
    } finally {
      if (!identical(finalImage, cameraImage)) {
        finalImage.dispose();
      }
      overlayImage?.dispose();
      cameraImage.dispose();
      cameraCodec.dispose();
    }
  }
}
