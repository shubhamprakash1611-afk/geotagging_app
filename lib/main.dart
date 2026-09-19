import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart' as cam;
import 'package:provider/provider.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import 'app.dart';
import 'providers/app_state_provider.dart';
import 'services/security_service.dart';

List<cam.CameraDescription> availableCameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('mapStore').manage.createAsync();
  } catch (e) {
    debugPrint('FMTC Init error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await SecurityService.initialize();

  try {
    availableCameras = await cam.availableCameras();
  } catch (e) {
    debugPrint('Camera error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: const GeoTaggingApp(),
    ),
  );
}
