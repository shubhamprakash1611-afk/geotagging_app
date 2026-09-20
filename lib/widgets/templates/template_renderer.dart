import 'package:flutter/material.dart';
import '../../models/location_data.dart';
import '../../models/weather_data.dart';
import '../../models/sensor_data.dart';
import '../../models/settings_data.dart';

import 'advance_template.dart';
import 'advance2_template.dart';
import 'datetime_template.dart';
import 'scan_location_template.dart';
import 'classic_template.dart';
import 'reporting_template.dart';
import 'navigation_template.dart';

class TemplateRenderer extends StatelessWidget {
  final String templateId;
  final LocationData loc;
  final WeatherData weather;
  final SensorData sensor;
  final SettingsData settings;
  final String userNote;

  const TemplateRenderer({
    super.key,
    required this.templateId,
    required this.loc,
    required this.weather,
    required this.sensor,
    required this.settings,
    required this.userNote,
  });

  @override
  Widget build(BuildContext context) {
    switch (templateId) {
      case 'advance2':
        return Advance2Template(
          loc: loc,
          weather: weather,
          sensor: sensor,
          settings: settings,
          userNote: userNote,
        );
      case 'datetime':
        return DateTimeTemplate(loc: loc);
      case 'scan_location':
        return ScanLocationTemplate(loc: loc, settings: settings);
      case 'classic':
        return ClassicTemplate(loc: loc);
      case 'reporting':
        return ReportingTemplate(loc: loc);
      case 'navigation':
        return NavigationTemplate(loc: loc, sensor: sensor);
      case 'advance':
      default:
        return AdvanceTemplate(
          loc: loc,
          weather: weather,
          sensor: sensor,
          settings: settings,
          userNote: userNote,
        );
    }
  }
}

