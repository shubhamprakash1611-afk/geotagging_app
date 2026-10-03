import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'language_update_card.dart';
import 'location_loading_card.dart';
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

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: state.isLanguageChanging
              ? LanguageUpdateCard(
                  key: const ValueKey('language-loader'),
                  language: state.settings.language,
                  compact: true,
                )
              : state.isLocationLoading && !state.locationAvailable
                  ? LocationLoadingCard(
                      key: const ValueKey('location-loader'),
                      language: state.settings.language,
                      compact: true,
                    )
                  : MediaQuery(
                      key: ValueKey(
                        '${state.settings.language.name}-'
                        '${state.settings.activeTemplateId}',
                      ),
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
                    ),
        );
      },
    );
  }
}
