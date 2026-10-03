import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/template_data.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_translations.dart';
import '../utils/constants.dart';
import '../widgets/language_update_card.dart';
import '../widgets/location_loading_card.dart';
import '../widgets/templates/template_renderer.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        final t = AppTranslations(state.settings.language);
        final isDataLoading = state.isLanguageChanging ||
            (state.isLocationLoading && !state.locationAvailable);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            titleSpacing: 4,
            title: Text(
              t.text('template'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.surfaceGradient),
            ),
          ),
          body: Stack(
            children: [
              IgnorePointer(
                ignoring: isDataLoading,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
                  itemCount: GeoTagTemplate.allTemplates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final template = GeoTagTemplate.allTemplates[index];
                    return _TemplateCard(
                      template: template,
                      isSelected:
                          state.settings.activeTemplateId == template.id,
                      translations: t,
                      state: state,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !isDataLoading,
                  child: AnimatedOpacity(
                    opacity: isDataLoading ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: ColoredBox(
                      color: AppColors.background.withValues(alpha: 0.94),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: state.isLanguageChanging
                              ? LanguageUpdateCard(
                                  language: state.settings.language,
                                )
                              : LocationLoadingCard(
                                  language: state.settings.language,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final GeoTagTemplate template;
  final bool isSelected;
  final AppTranslations translations;
  final AppStateProvider state;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.translations,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isSelected
        ? AppColors.accentGreen
        : Colors.white.withValues(alpha: 0.09);

    return Semantics(
      selected: isSelected,
      button: true,
      label: translations.templateName(template.id),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => state.updateSettings(
            state.settings.copyWith(activeTemplateId: template.id),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? const [Color(0xFF182A33), AppColors.surfaceDark]
                    : const [AppColors.surfaceRaised, AppColors.surfaceDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent, width: isSelected ? 1.5 : 1),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected
                            ? null
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.layers_outlined,
                        color: isSelected
                            ? const Color(0xFF042117)
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  translations.templateName(template.id),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (template.isNew) ...[
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentViolet
                                        .withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    translations.text('new'),
                                    style: const TextStyle(
                                      color: AppColors.accentViolet,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            translations.templateDescription(template.id),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              height: 1.28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentGreen.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.045),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSelected
                            ? translations.text('selected')
                            : translations.text('tapToUse'),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accentGreen
                              : AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  clipBehavior: Clip.antiAlias,
                  constraints: const BoxConstraints(minHeight: 154),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentGreen.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(0.75, -0.9),
                              radius: 1.4,
                              colors: [
                                Color(0x332A78C7),
                                Color(0xFF0C1421),
                                Color(0xFF060A12),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.noScaling,
                          ),
                          child: TemplateRenderer(
                            templateId: template.id,
                            loc: state.location,
                            weather: state.weather,
                            sensor: state.sensor,
                            settings: state.settings,
                            userNote: state.userNote,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
