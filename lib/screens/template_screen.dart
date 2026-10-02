import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/template_data.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_translations.dart';
import '../utils/constants.dart';
import '../widgets/templates/template_renderer.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        final t = AppTranslations(state.settings.language);

        return Scaffold(
          backgroundColor: const Color(0xFFF2F5F4),
          appBar: AppBar(
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 4,
            title: Text(t.text('template'),
                style: const TextStyle(fontWeight: FontWeight.w800)),
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF17233C), Color(0xFF0B1220)]),
              ),
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 28),
            itemCount: GeoTagTemplate.allTemplates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final template = GeoTagTemplate.allTemplates[index];
              final isSelected = state.settings.activeTemplateId == template.id;

              return Semantics(
                selected: isSelected,
                button: true,
                label: t.templateName(template.id),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => state.updateSettings(
                      state.settings.copyWith(activeTemplateId: template.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          t.templateName(template.id),
                                          style: const TextStyle(
                                              color: Color(0xFF182230),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      if (template.isNew) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFFFE8DE),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(t.text('new'),
                                              style: const TextStyle(
                                                  color: Color(0xFFC2410C),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(t.templateDescription(template.id),
                                      style: const TextStyle(
                                          color: Color(0xFF667085),
                                          fontSize: 11.5,
                                          height: 1.25)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentGreen
                                    : const Color(0xFFE7ECEA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.touch_app_outlined,
                                      size: 14,
                                      color: isSelected
                                          ? const Color(0xFF052E16)
                                          : const Color(0xFF667085)),
                                  const SizedBox(width: 4),
                                  Text(
                                      isSelected
                                          ? t.text('selected')
                                          : t.text('tapToUse'),
                                      style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF052E16)
                                              : const Color(0xFF667085),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        clipBehavior: Clip.antiAlias,
                        constraints: const BoxConstraints(minHeight: 154),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.accentGreen
                                  : Colors.white,
                              width: isSelected ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                                color: isSelected
                                    ? AppColors.accentGreen
                                        .withValues(alpha: 0.18)
                                    : Colors.black12,
                                blurRadius: 18,
                                offset: const Offset(0, 7)),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.white.withValues(alpha: 0.45),
                                    BlendMode.srcATop),
                                child: Image.asset('assets/images/app_logo.png',
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.black.withValues(alpha: 0.08)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: MediaQuery(
                                data: MediaQuery.of(context)
                                    .copyWith(textScaler: TextScaler.noScaling),
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
              );
            },
          ),
        );
      },
    );
  }
}
