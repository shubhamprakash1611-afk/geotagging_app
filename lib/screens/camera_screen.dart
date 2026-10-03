import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' hide availableCameras;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../main.dart' show availableCameras;
import '../providers/app_state_provider.dart';
import '../models/settings_data.dart';
import '../services/image_compilation_service.dart';
import 'settings_screen.dart';
import 'template_screen.dart';
import 'locations_screen.dart';
import '../widgets/top_controls_bar.dart';
import '../widgets/capture_aspect_ratio_selector.dart';
import '../widgets/grid_overlay.dart';
import '../widgets/focus_bracket.dart';
import '../widgets/dashboard_overlay.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/constants.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isFrontScreenFlashActive = false;
  bool _isAspectSelectorVisible = false;
  ImageResolution _currentResolution = ImageResolution.high;

  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _bottomControlsKey = GlobalKey();
  double? _bottomControlsHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();

    // Start fetching data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().initializeAllServices();
    });
  }

  Future<void> _initializeCamera() async {
    if (availableCameras.isEmpty) return;

    final appState = context.read<AppStateProvider>();

    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _currentResolution = appState.settings.imageResolution;

    _cameraController = CameraController(
      availableCameras[_currentCameraIndex],
      appState.settings.toResolutionPreset(),
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });

      // The flash toggle represents flash-on-capture, never a torch. Keeping
      // the hardware flash off here also prevents exposure from changing as
      // the camera opens or is flipped.
      await _cameraController!.setFlashMode(FlashMode.off);
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
        await _cameraController!.setExposureMode(ExposureMode.auto);
      } catch (error) {
        // A few vendor camera HALs do not expose one of these controls. Their
        // default continuous modes are still safe to use.
        debugPrint('Automatic focus/exposure unavailable: $error');
      }
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isFrontScreenFlashActive) {
      unawaited(ImageCompilationService.endScreenFlash());
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      setState(() => _isCameraReady = false);
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  int _currentCameraIndex = 0;

  bool get _isFrontCamera =>
      availableCameras.isNotEmpty &&
      availableCameras[_currentCameraIndex].lensDirection ==
          CameraLensDirection.front;

  double _targetAspectRatio(CaptureAspectRatio ratio, Size viewport) {
    switch (ratio) {
      case CaptureAspectRatio.ratio4x3:
        return 3 / 4;
      case CaptureAspectRatio.ratio9x16:
        return 9 / 16;
      case CaptureAspectRatio.square:
        return 1;
      case CaptureAspectRatio.full:
        return viewport.aspectRatio;
    }
  }

  Rect _captureRect(Size viewport, CaptureAspectRatio ratio) {
    final targetAspectRatio = _targetAspectRatio(ratio, viewport);
    var width = viewport.width;
    var height = width / targetAspectRatio;
    if (height > viewport.height) {
      height = viewport.height;
      width = height * targetAspectRatio;
    }
    return Rect.fromLTWH(
      (viewport.width - width) / 2,
      (viewport.height - height) / 2,
      width,
      height,
    );
  }

  Widget _cameraPreviewFor(Rect captureRect) {
    final previewSize = _cameraController!.value.previewSize;
    final previewWidth = previewSize?.height ?? captureRect.width;
    final previewHeight = previewSize?.width ?? captureRect.height;
    return Positioned.fromRect(
      rect: captureRect,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewWidth,
            height: previewHeight,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  Future<void> _prepareFlashForCapture(bool enabled) async {
    final controller = _cameraController;
    if (controller?.value.isInitialized != true) return;

    // Clear any stale state left by a previous camera session first.
    await controller!.setFlashMode(FlashMode.off);
    if (!enabled) return;

    if (_isFrontCamera) {
      await ImageCompilationService.beginScreenFlash();
      if (!mounted) return;
      setState(() => _isFrontScreenFlashActive = true);
      await WidgetsBinding.instance.endOfFrame;
      // Give the front camera's auto-exposure a brief moment to react to the
      // illuminated screen before releasing the shutter.
      await Future<void>.delayed(const Duration(milliseconds: 180));
    } else {
      // `always` is a still-capture flash. Unlike `torch`, it only illuminates
      // while takePicture performs its metering/pre-flash and exposure.
      await controller.setFlashMode(FlashMode.always);
    }
  }

  Future<void> _resetFlashAfterCapture() async {
    if (_isFrontScreenFlashActive) {
      if (mounted) {
        setState(() => _isFrontScreenFlashActive = false);
      }
      await ImageCompilationService.endScreenFlash();
    }

    final controller = _cameraController;
    if (controller?.value.isInitialized == true) {
      try {
        await controller!.setFlashMode(FlashMode.off);
      } catch (error) {
        debugPrint('Unable to reset flash: $error');
      }
    }
  }

  Future<void> _onCameraFlip() async {
    if (availableCameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other camera available')),
      );
      return;
    }
    setState(() => _isCameraReady = false);
    _currentCameraIndex = (_currentCameraIndex + 1) % availableCameras.length;
    await _initializeCamera();
  }

  Future<void> _onShutterPressed() async {
    final appState = context.read<AppStateProvider>();
    final targetAspectRatio = _targetAspectRatio(
      appState.settings.captureAspectRatio,
      MediaQuery.sizeOf(context),
    );
    if (appState.isCapturing ||
        appState.isLanguageChanging ||
        (appState.settings.geoTagEnabled && appState.isLocationLoading) ||
        _cameraController?.value.isInitialized != true) {
      return;
    }

    final captureStopwatch = Stopwatch()..start();
    appState.setCapturing(true);

    try {
      late final XFile file;
      try {
        await _prepareFlashForCapture(appState.isFlashOn);
        file = await _cameraController!.takePicture();
      } finally {
        await _resetFlashAfterCapture();
      }

      // Play shutter sound if enabled
      if (appState.settings.shutterSoundEnabled) {
        final player = AudioPlayer();
        player.play(AssetSource('sounds/shutter.mp3')).catchError((_) {});
      }

      // Capture only the relatively small overlay on Flutter's UI thread.
      // Full-resolution photo work is delegated to native background workers.
      ui.Image? overlayUiImage;
      if (appState.settings.geoTagEnabled) {
        final boundary = _dashboardKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        if (boundary != null &&
            boundary.size.width > 0 &&
            boundary.size.height > 0) {
          overlayUiImage = await boundary.toImage(pixelRatio: 2.0);
        }
      }

      // Release the shutter immediately; gallery work continues separately.
      appState.setCapturing(false);

      // Save settings snapshot for background work
      final settingsSnapshot = appState.settings;

      // Native Android JPEG compositing and MediaStore publication run in the
      // background, allowing another photo to be taken immediately.
      ImageCompilationService.burnAndSave(
        cameraImagePath: file.path,
        overlayUiImage: overlayUiImage,
        settings: settingsSnapshot,
        targetAspectRatio: targetAspectRatio,
      ).then((success) {
        debugPrint(
          'Capture-to-gallery ${success ? 'completed' : 'failed'} '
          'in ${captureStopwatch.elapsedMilliseconds}ms',
        );
        if (settingsSnapshot.hapticFeedbackEnabled && success) {
          HapticFeedback.vibrate();
        }
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Photo saved to gallery'
                    : 'Failed to save photo'),
                backgroundColor: success ? Colors.green[700] : Colors.red[700],
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 184),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
        }
      });
    } catch (e) {
      debugPrint('Capture error: $e');
      appState.setCapturing(false);
    }
  }

  void _measureBottomControls() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox =
          _bottomControlsKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;

      final measuredHeight = renderBox.size.height;
      if ((_bottomControlsHeight ?? 0) - measuredHeight > -0.5 &&
          (_bottomControlsHeight ?? 0) - measuredHeight < 0.5) {
        return;
      }
      setState(() => _bottomControlsHeight = measuredHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.accentGreen)),
      );
    }

    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        if (state.settings.imageResolution != _currentResolution) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeCamera();
          });
        }

        final isOverlayLoading = state.settings.geoTagEnabled &&
            (state.isLanguageChanging || state.isLocationLoading);

        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              _measureBottomControls();
              final bottomControlsHeight = _bottomControlsHeight ??
                  (constraints.maxHeight * 0.23).clamp(178.0, 200.0);
              final viewport = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final captureRect =
                  _captureRect(viewport, state.settings.captureAspectRatio);
              final dashboardBottom =
                  (constraints.maxHeight - captureRect.bottom + 12)
                      .clamp(bottomControlsHeight + 10, double.infinity)
                      .toDouble();
              final dashboardTop = captureRect.top
                  .clamp(
                      MediaQuery.paddingOf(context).top + 78, double.infinity)
                  .toDouble();

              return Stack(
                children: [
                  const Positioned.fill(child: ColoredBox(color: Colors.black)),

                  // The viewfinder and native compositor use the same target
                  // ratio. Changing it never restarts the camera.
                  _cameraPreviewFor(captureRect),

                  // Layer 2: Grid Overlay (togglable)
                  if (state.isGridVisible)
                    Positioned.fromRect(
                      rect: captureRect,
                      child: const ClipRect(child: GridOverlay()),
                    ),

                  // Layer 3: Focus Brackets (center)
                  Positioned.fromRect(
                    rect: captureRect,
                    child: const Center(child: FocusBracket()),
                  ),

                  // Layer 4: Top Controls
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopControlsBar(
                      onFlashToggled: () async {
                        if (_cameraController != null &&
                            _cameraController!.value.isInitialized) {
                          try {
                            // The icon arms flash for the next capture. It must
                            // not turn the rear LED into a continuous torch.
                            await _cameraController!
                                .setFlashMode(FlashMode.off);
                          } catch (e) {
                            debugPrint('Flash toggle error: $e');
                          }
                        }
                      },
                      onAspectRatioPressed: () {
                        setState(() => _isAspectSelectorVisible =
                            !_isAspectSelectorVisible);
                      },
                      onSettingsPressed: () {
                        setState(() => _isAspectSelectorVisible = false);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const SettingsScreen(),
                        );
                      },
                    ),
                  ),

                  if (_isAspectSelectorVisible)
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 66,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: CaptureAspectRatioSelector(
                          selected: state.settings.captureAspectRatio,
                          onChanged: (ratio) {
                            state.updateSettings(
                              state.settings
                                  .copyWith(captureAspectRatio: ratio),
                            );
                            setState(() => _isAspectSelectorVisible = false);
                          },
                        ),
                      ),
                    ),

                  // Layer 5 (Now part of BottomNavBar)
                  // Layer 6: Dashboard Overlay (wrapped in RepaintBoundary for burning)
                  Positioned(
                    bottom:
                        state.settings.geoTagPlacement == GeoTagPlacement.bottom
                            ? dashboardBottom
                            : null,
                    top: state.settings.geoTagPlacement == GeoTagPlacement.top
                        ? dashboardTop
                        : null,
                    left: captureRect.left + 12,
                    right: constraints.maxWidth - captureRect.right + 12,
                    child: RepaintBoundary(
                      key: _dashboardKey,
                      child: const DashboardOverlay(),
                    ),
                  ),

                  // Layer 7: Bottom Nav Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: KeyedSubtree(
                      key: _bottomControlsKey,
                      child: BottomNavBar(
                        isCapturing: state.isCapturing || isOverlayLoading,
                        hapticFeedbackEnabled:
                            state.settings.hapticFeedbackEnabled,
                        language: state.settings.language,
                        onZoomChanged: (zoom) async {
                          if (_cameraController != null) {
                            try {
                              await _cameraController!.setZoomLevel(zoom);
                            } catch (e) {
                              debugPrint('Zoom error: $e');
                            }
                          }
                        },
                        onShutterPressed: _onShutterPressed,
                        onCollectionPressed: () async {
                          final opened =
                              await ImageCompilationService.openCollection(
                            directory: state.settings.saveDirectory,
                          );
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No GeoTag photos found. Take a photo first.',
                                ),
                              ),
                            );
                          }
                        },
                        onMapDataPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LocationsScreen()),
                          );
                        },
                        onCameraFlipPressed: _onCameraFlip,
                        onTemplatesPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TemplateScreen()),
                          );
                        },
                      ),
                    ),
                  ),

                  // Front-facing cameras normally have no LED. When flash is
                  // armed, a bright white frame plus maximum display
                  // brightness provides the conventional selfie flash.
                  if (_isFrontScreenFlashActive)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(color: Colors.white),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
