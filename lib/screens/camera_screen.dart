import 'dart:ui' as ui;
import 'dart:typed_data';
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
import '../widgets/zoom_mode_selector.dart';
import '../widgets/dashboard_overlay.dart';
import '../widgets/bottom_nav_bar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
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

    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    final appState = context.read<AppStateProvider>();
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

      final appState = context.read<AppStateProvider>();
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
    if (appState.isCapturing) return; // Debounce

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

      // Read camera bytes
      final Uint8List cameraBytes = await file.readAsBytes();

      // Capture the overlay widget to PNG (must happen on main thread)
      Uint8List? overlayBytes;
      if (appState.settings.geoTagEnabled) {
        final boundary = _dashboardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null && boundary.size.width > 0 && boundary.size.height > 0) {
          final ui.Image overlayUiImage = await boundary.toImage(pixelRatio: 2.0);
          final ByteData? byteData = await overlayUiImage.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            overlayBytes = byteData.buffer.asUint8List();
          }
        }
      }

      // Release the spinner immediately — user can take another photo now
      appState.setCapturing(false);

      // Save settings snapshot for background work
      final settingsSnapshot = appState.settings;

      // Fire-and-forget: heavy compositing + gallery save runs in background
      ImageCompilationService.burnAndSaveFromBytes(
        cameraImageBytes: cameraBytes,
        overlayBytes: overlayBytes,
        settings: settingsSnapshot,
      ).then((success) {
        if (settingsSnapshot.hapticFeedbackEnabled && success) {
          HapticFeedback.vibrate();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '✅ Photo saved to gallery!' : '❌ Failed to save photo'),
              backgroundColor: success ? Colors.green[700] : Colors.red[700],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
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
          body: Stack(
            children: [
              // Layer 1: Camera Preview (full screen)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              ),

              // Layer 2: Grid Overlay (togglable)
              if (state.isGridVisible)
                const Positioned.fill(child: GridOverlay()),

              // Layer 3: Focus Brackets (center)
              const Center(child: FocusBracket()),

              // Layer 4: Top Controls
              Positioned(
                top: 0, left: 0, right: 0,
                child: TopControlsBar(
                  onFlashToggled: () async {
                    if (_cameraController != null && _cameraController!.value.isInitialized) {
                      try {
                        final appState = context.read<AppStateProvider>();
                        await _cameraController!.setFlashMode(
                          appState.isFlashOn ? FlashMode.torch : FlashMode.off,
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
                      backgroundColor: Colors.transparent,
                      builder: (_) => const SettingsScreen(),
                    );
                  },
                ),
              ),

              // Layer 5 (Now part of BottomNavBar)
              // Layer 6: Dashboard Overlay (wrapped in RepaintBoundary for burning)
              Positioned(
                bottom: state.settings.geoTagPlacement == GeoTagPlacement.bottom ? 250 : null,
                top: state.settings.geoTagPlacement == GeoTagPlacement.top ? 120 : null,
                left: 10, right: 10,
                child: RepaintBoundary(
                  key: _dashboardKey,
                  child: const DashboardOverlay(),
                ),
              ),

              // Layer 7: Bottom Nav Bar
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: BottomNavBar(
                  isCapturing: state.isCapturing,
                  hapticFeedbackEnabled: state.settings.hapticFeedbackEnabled,
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
                    final uri = Uri.parse('content://media/external/images/media');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  onMapDataPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LocationsScreen()),
                    );
                  },
                  onCameraFlipPressed: _onCameraFlip,
                  onTemplatesPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TemplateScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
