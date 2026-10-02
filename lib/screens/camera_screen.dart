import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' hide availableCameras;
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart' show availableCameras;
import '../providers/app_state_provider.dart';
import '../models/settings_data.dart';
import '../services/image_compilation_service.dart';
import 'settings_screen.dart';
import 'template_screen.dart';
import 'locations_screen.dart';
import '../widgets/top_controls_bar.dart';
import '../widgets/grid_overlay.dart';
import '../widgets/focus_bracket.dart';
import '../widgets/dashboard_overlay.dart';
import '../widgets/bottom_nav_bar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  ImageResolution _currentResolution = ImageResolution.high;

  final GlobalKey _dashboardKey = GlobalKey();

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
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });

      await _cameraController!.setFlashMode(
        appState.isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    if (appState.isCapturing ||
        _cameraController?.value.isInitialized != true) {
      return;
    }

    final captureStopwatch = Stopwatch()..start();
    appState.setCapturing(true);

    try {
      // Apply flash setting
      await _cameraController!.setFlashMode(
        appState.isFlashOn ? FlashMode.always : FlashMode.off,
      );

      // Take photo
      final XFile file = await _cameraController!.takePicture();

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
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 225),
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

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
      );
    }

    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        if (state.settings.imageResolution != _currentResolution) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeCamera();
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bottomControlsHeight =
                  (constraints.maxHeight * 0.235).clamp(184.0, 224.0);

              return Stack(
                children: [
                  // Layer 1: Camera Preview (letterboxed to preserve exact field of view)
                  Positioned.fill(
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Grid Overlay (togglable)
                  if (state.isGridVisible)
                    const Positioned.fill(child: GridOverlay()),

                  // Layer 3: Focus Brackets (center)
                  const Center(child: FocusBracket()),

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
                            final appState = context.read<AppStateProvider>();
                            await _cameraController!.setFlashMode(
                              appState.isFlashOn
                                  ? FlashMode.torch
                                  : FlashMode.off,
                            );
                          } catch (e) {
                            debugPrint('Flash toggle error: $e');
                          }
                        }
                      },
                      onSettingsPressed: () {
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

                  // Layer 5 (Now part of BottomNavBar)
                  // Layer 6: Dashboard Overlay (wrapped in RepaintBoundary for burning)
                  Positioned(
                    bottom:
                        state.settings.geoTagPlacement == GeoTagPlacement.bottom
                            ? bottomControlsHeight + 10
                            : null,
                    top: state.settings.geoTagPlacement == GeoTagPlacement.top
                        ? MediaQuery.paddingOf(context).top + 78
                        : null,
                    left: 12,
                    right: 12,
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
                    child: BottomNavBar(
                      isCapturing: state.isCapturing,
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
                        final uri =
                            Uri.parse('content://media/external/images/media');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
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
                ],
              );
            },
          ),
        );
      },
    );
  }
}
