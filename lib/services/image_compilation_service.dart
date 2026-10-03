import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../models/settings_data.dart';

class ImageCompilationService {
  static const MethodChannel _androidCompositor =
      MethodChannel('com.geotagging.app/image_compositor');

  /// Temporarily maximizes Android display brightness for a selfie flash.
  static Future<void> beginScreenFlash() async {
    if (!Platform.isAndroid) return;
    try {
      await _androidCompositor.invokeMethod<void>('beginScreenFlash');
    } catch (error) {
      debugPrint('Unable to start screen flash: $error');
    }
  }

  /// Restores the display brightness that was active before selfie flash.
  static Future<void> endScreenFlash() async {
    if (!Platform.isAndroid) return;
    try {
      await _androidCompositor.invokeMethod<void>('endScreenFlash');
    } catch (error) {
      debugPrint('Unable to stop screen flash: $error');
    }
  }

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
    required double targetAspectRatio,
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
            // The camera JPEG must be decoded to burn in the template. Keep
            // the unavoidable second JPEG pass visually near-lossless.
            'jpegQuality': 98,
            'targetAspectRatio': targetAspectRatio,
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
        targetAspectRatio: targetAspectRatio,
      );
    } catch (error, stackTrace) {
      debugPrint('Image compilation failed: $error\n$stackTrace');
      return false;
    } finally {
      overlayUiImage?.dispose();
    }
  }

  /// Opens the newest image in this app's MediaStore collection.
  ///
  /// A generic `content://media/...` launch lets gallery apps choose their
  /// home screen. The native implementation queries the configured GeoTag
  /// directory and opens its newest image URI directly instead.
  static Future<bool> openCollection({required String directory}) async {
    if (!Platform.isAndroid) return false;

    try {
      return await _androidCompositor.invokeMethod<bool>(
            'openCollection',
            {'directory': directory},
          ) ??
          false;
    } catch (error) {
      debugPrint('Unable to open GeoTag collection: $error');
      return false;
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
    required double targetAspectRatio,
  }) async {
    final cameraBytes = await File(cameraImagePath).readAsBytes();
    final cameraCodec = await ui.instantiateImageCodec(cameraBytes);
    final cameraFrame = await cameraCodec.getNextFrame();
    final cameraImage = cameraFrame.image;

    ui.Image? overlayImage;
    ui.Image? finalImage;

    try {
      final sourceAspectRatio = cameraImage.width / cameraImage.height;
      late final ui.Rect sourceRect;
      if (sourceAspectRatio > targetAspectRatio) {
        final cropWidth = cameraImage.height * targetAspectRatio;
        sourceRect = ui.Rect.fromLTWH(
          (cameraImage.width - cropWidth) / 2,
          0,
          cropWidth,
          cameraImage.height.toDouble(),
        );
      } else {
        final cropHeight = cameraImage.width / targetAspectRatio;
        sourceRect = ui.Rect.fromLTWH(
          0,
          (cameraImage.height - cropHeight) / 2,
          cameraImage.width.toDouble(),
          cropHeight,
        );
      }

      final outputWidth = sourceRect.width.round();
      final outputHeight = sourceRect.height.round();
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawImageRect(
        cameraImage,
        sourceRect,
        ui.Rect.fromLTWH(
          0,
          0,
          outputWidth.toDouble(),
          outputHeight.toDouble(),
        ),
        ui.Paint()..filterQuality = ui.FilterQuality.high,
      );

      if (overlayBytes != null && settings.geoTagEnabled) {
        final overlayCodec = await ui.instantiateImageCodec(overlayBytes);
        final overlayFrame = await overlayCodec.getNextFrame();
        overlayImage = overlayFrame.image;

        final targetWidth = outputWidth * 0.95;
        final scale = targetWidth / overlayImage.width;
        final scaledHeight = overlayImage.height * scale;
        final destinationX = (outputWidth - targetWidth) / 2;
        final destinationY = settings.geoTagPlacement == GeoTagPlacement.top
            ? outputHeight * 0.03
            : outputHeight - scaledHeight - (outputHeight * 0.03);

        canvas
          ..save()
          ..translate(destinationX, destinationY)
          ..scale(scale)
          ..drawImage(overlayImage, ui.Offset.zero, ui.Paint())
          ..restore();
      }

      final picture = recorder.endRecording();
      finalImage = await picture.toImage(outputWidth, outputHeight);
      picture.dispose();

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
      finalImage?.dispose();
      overlayImage?.dispose();
      cameraImage.dispose();
      cameraCodec.dispose();
    }
  }
}
