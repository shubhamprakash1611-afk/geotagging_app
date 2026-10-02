import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geotagging_app/models/location_data.dart';
import 'package:geotagging_app/models/sensor_data.dart';
import 'package:geotagging_app/models/settings_data.dart';
import 'package:geotagging_app/models/weather_data.dart';
import 'package:geotagging_app/providers/app_state_provider.dart';
import 'package:geotagging_app/widgets/templates/template_renderer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US');
    await initializeDateFormatting('hi_IN');
  });

  testWidgets('all templates fit a narrow phone in both languages',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    for (final language in AppLanguage.values) {
      final settings =
          SettingsData.defaultSettings.copyWith(language: language);

      for (final templateId in const [
        'advance',
        'advance2',
        'datetime',
        'scan_location',
        'classic',
        'reporting',
        'navigation',
      ]) {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 304,
                    child: TemplateRenderer(
                      templateId: templateId,
                      loc: LocationData.empty(),
                      weather: const WeatherData(
                        temperatureCelsius: 31.2,
                        windSpeedKmh: 8.4,
                        humidityPercent: 72,
                      ),
                      sensor: const SensorData(
                        magneticFieldMicroTesla: 43.3,
                        azimuth: 31.7,
                      ),
                      settings: settings,
                      userNote: language == AppLanguage.hi
                          ? 'साइट का निरीक्षण पूरा हुआ'
                          : 'Site inspection completed',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: '$templateId overflowed in ${language.name}',
        );
      }
    }
  });
}
