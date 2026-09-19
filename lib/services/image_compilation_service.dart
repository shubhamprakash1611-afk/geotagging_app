import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter/material.dart';
import '../models/settings_data.dart';

/// Payload sent to the background isolate for image compositing.
class _CompilePayload {
  final Uint8List cameraBytes;
  final Uint8List? overlayBytes;
  final bool placeOnTop;

  _CompilePayload({
    required this.cameraBytes,
    this.overlayBytes,
    required this.placeOnTop,
  });
}

/// Runs entirely in a background isolate — no UI thread blocking.
Uint8List _compileInIsolate(_CompilePayload payload) {
  final bgImage = img.decodeJpg(payload.cameraBytes);
  if (bgImage == null) return payload.cameraBytes;

  if (payload.overlayBytes != null) {
    final overlayImage = img.decodePng(payload.overlayBytes!);
    if (overlayImage != null) {
      final targetWidth = (bgImage.width * 0.95).toInt();
      final resizedOverlay = img.copyResize(overlayImage, width: targetWidth);

      final dstX = (bgImage.width - targetWidth) ~/ 2;
      int dstY;
      if (!payload.placeOnTop) {
        final bottomMargin = (bgImage.height * 0.03).toInt();
        dstY = bgImage.height - resizedOverlay.height - bottomMargin;
      } else {
        final topMargin = (bgImage.height * 0.03).toInt();
        dstY = topMargin;
      }

      img.compositeImage(bgImage, resizedOverlay, dstX: dstX, dstY: dstY);
    }
  }

  return Uint8List.fromList(img.encodeJpg(bgImage, quality: 92));
}

class ImageCompilationService {

  /// New optimized method: overlay bytes already captured by caller.
  /// Heavy work (decode, composite, encode) runs in a background isolate.
  static Future<bool> burnAndSaveFromBytes({
    required Uint8List cameraImageBytes,
    Uint8List? overlayBytes,
    required SettingsData settings,
  }) async {
    try {
      // Heavy work in background isolate
      final finalBytes = await compute(
        _compileInIsolate,
        _CompilePayload(
          cameraBytes: cameraImageBytes,
          overlayBytes: overlayBytes,
          placeOnTop: settings.geoTagPlacement == GeoTagPlacement.top,
        ),
      );

      // Save to gallery (platform channel, fast)
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

  /// Legacy method kept for compatibility.
  static Future<bool> burnAndSave({
    required GlobalKey dashboardKey,
    required Uint8List cameraImageBytes,
    required SettingsData settings,
  }) async {
    try {
      Uint8List? overlayBytes;
      if (settings.geoTagEnabled) {
        final boundary = dashboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null && boundary.size.width > 0 && boundary.size.height > 0) {
          final ui.Image overlayUiImage = await boundary.toImage(pixelRatio: 2.0);
          final ByteData? byteData = await overlayUiImage.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            overlayBytes = byteData.buffer.asUint8List();
          }
        }
      }

      return burnAndSaveFromBytes(
        cameraImageBytes: cameraImageBytes,
        overlayBytes: overlayBytes,
        settings: settings,
      );
    } catch (e) {
      debugPrint('Image compilation failed: $e');
      return false;
    }
  }
}

