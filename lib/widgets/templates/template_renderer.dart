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
  static const double _designWidth = 360;

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
    late final Widget template;
    switch (templateId) {
      case 'advance2':
        template = Advance2Template(
          loc: loc,
          weather: weather,
          sensor: sensor,
          settings: settings,
          userNote: userNote,
        );
        break;
      case 'datetime':
        template = DateTimeTemplate(loc: loc, settings: settings);
        break;
      case 'scan_location':
        template = ScanLocationTemplate(loc: loc, settings: settings);
        break;
      case 'classic':
        template = ClassicTemplate(loc: loc, settings: settings);
        break;
      case 'reporting':
        template = ReportingTemplate(loc: loc, settings: settings);
        break;
      case 'navigation':
        template =
            NavigationTemplate(loc: loc, sensor: sensor, settings: settings);
        break;
      case 'advance':
      default:
        template = AdvanceTemplate(
          loc: loc,
          weather: weather,
          sensor: sensor,
          settings: settings,
          userNote: userNote,
        );
        break;
    }

    // Templates are photo composition assets, not ordinary application text.
    // Keep their physical design stable when Android font/display scaling is
    // increased so the live preview matches the pixels burned into the photo.
    final mediaQuery = MediaQuery.maybeOf(context);
    final fixedTemplate = IconTheme.merge(
      data: const IconThemeData(size: 20),
      child: template,
    );
    final fixedAccessibilityTemplate = mediaQuery == null
        ? fixedTemplate
        : MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
            child: fixedTemplate,
          );

    // Build every template on one stable design canvas and fit that canvas to
    // the available width. Android's Display size changes the logical screen
    // width and pixel density in opposite directions; this arrangement keeps
    // internal text, icons, padding, and the final burned-photo proportions
    // physically stable instead of rebuilding them at the enlarged density.
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvas = SizedBox(
          width: _designWidth,
          child: fixedAccessibilityTemplate,
        );
        if (!constraints.maxWidth.isFinite) return canvas;

        return FittedBox(
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          child: canvas,
        );
      },
    );
  }
}
