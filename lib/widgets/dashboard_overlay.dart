import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'templates/template_renderer.dart';

class DashboardOverlay extends StatelessWidget {
  const DashboardOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, child) {
        if (!state.settings.geoTagEnabled) {
          return const SizedBox.shrink();
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: TemplateRenderer(
            templateId: state.settings.activeTemplateId,
            loc: state.location,
            weather: state.weather,
            sensor: state.sensor,
            settings: state.settings,
            userNote: state.userNote,
          ),
        );
      },
    );
  }
}
