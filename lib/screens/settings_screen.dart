import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_data.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_translations.dart';
import '../utils/constants.dart';
import 'template_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        final settings = state.settings;
        final t = AppTranslations(settings.language);

        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.94,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF121827), Color(0xFF090D17)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color:
                                  AppColors.accentGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.tune_rounded,
                              color: AppColors.accentGreen, size: 20),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(t.text('settings'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(context)
                              .closeButtonTooltip,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                      children: [
                        _Section(
                          icon: Icons.layers_outlined,
                          title: t.text('geotagOverlay'),
                          children: [
                            _SwitchRow(
                              icon: Icons.pin_drop_outlined,
                              label: t.text('showGeotag'),
                              value: settings.geoTagEnabled,
                              onChanged: (value) => state.updateSettings(
                                  settings.copyWith(geoTagEnabled: value)),
                            ),
                            if (settings.geoTagEnabled) ...[
                              _SettingBlock(
                                label: t.text('placement'),
                                child: _Segmented<GeoTagPlacement>(
                                  segments: [
                                    ButtonSegment(
                                        value: GeoTagPlacement.top,
                                        icon: const Icon(
                                            Icons.vertical_align_top_rounded,
                                            size: 16),
                                        label: Text(t.text('top'))),
                                    ButtonSegment(
                                        value: GeoTagPlacement.bottom,
                                        icon: const Icon(
                                            Icons.vertical_align_bottom_rounded,
                                            size: 16),
                                        label: Text(t.text('bottom'))),
                                  ],
                                  selected: settings.geoTagPlacement,
                                  onChanged: (value) => state.updateSettings(
                                      settings.copyWith(
                                          geoTagPlacement: value)),
                                ),
                              ),
                              _ActionRow(
                                icon: Icons.dashboard_customize_outlined,
                                label: t.text('activeTemplate'),
                                value:
                                    t.templateName(settings.activeTemplateId),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const TemplateScreen())),
                              ),
                            ],
                          ],
                        ),
                        _Section(
                          icon: Icons.photo_camera_outlined,
                          title: t.text('camera'),
                          children: [
                            _SettingBlock(
                              label: t.text('imageResolution'),
                              child: _Segmented<ImageResolution>(
                                segments: [
                                  ButtonSegment(
                                      value: ImageResolution.low,
                                      label: Text(t.text('low'))),
                                  ButtonSegment(
                                      value: ImageResolution.medium,
                                      label: Text(t.text('medium'))),
                                  ButtonSegment(
                                      value: ImageResolution.high,
                                      label: Text(t.text('high'))),
                                ],
                                selected: settings.imageResolution,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(imageResolution: value)),
                              ),
                            ),
                            _SwitchRow(
                                icon: Icons.volume_up_outlined,
                                label: t.text('shutterSound'),
                                value: settings.shutterSoundEnabled,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(
                                        shutterSoundEnabled: value))),
                            _SwitchRow(
                                icon: Icons.vibration_rounded,
                                label: t.text('hapticFeedback'),
                                value: settings.hapticFeedbackEnabled,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(
                                        hapticFeedbackEnabled: value))),
                          ],
                        ),
                        _Section(
                          icon: Icons.map_outlined,
                          title: t.text('mapAndData'),
                          children: [
                            _SettingBlock(
                              label: t.text('mapType'),
                              child: _Segmented<MapType>(
                                segments: [
                                  ButtonSegment(
                                      value: MapType.street,
                                      icon: const Icon(Icons.map_outlined,
                                          size: 16),
                                      label: Text(t.text('street'))),
                                  ButtonSegment(
                                      value: MapType.earth,
                                      icon: const Icon(
                                          Icons.satellite_alt_outlined,
                                          size: 16),
                                      label: Text(t.text('earth'))),
                                ],
                                selected: settings.mapType,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(mapType: value)),
                              ),
                            ),
                            _SettingBlock(
                              label:
                                  '${t.text('mapZoom')} • ${settings.mapZoomLevel.toStringAsFixed(0)}×',
                              child: Slider(
                                value: settings.mapZoomLevel,
                                min: 10,
                                max: 18,
                                divisions: 8,
                                activeColor: AppColors.accentGreen,
                                inactiveColor: Colors.white12,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(mapZoomLevel: value)),
                              ),
                            ),
                            _SwitchRow(
                                icon: Icons.cloud_outlined,
                                label: t.text('weatherData'),
                                value: settings.showWeatherData,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(showWeatherData: value))),
                            _SwitchRow(
                                icon: Icons.sensors_outlined,
                                label: t.text('sensorData'),
                                value: settings.showSensorData,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(showSensorData: value))),
                          ],
                        ),
                        _Section(
                          icon: Icons.visibility_outlined,
                          title: t.text('display'),
                          children: [
                            _SwitchRow(
                                icon: Icons.add_location_alt_outlined,
                                label: t.text('plusCode'),
                                value: settings.showPlusCode,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(showPlusCode: value))),
                            _SwitchRow(
                                icon: Icons.branding_watermark_outlined,
                                label: t.text('watermark'),
                                value: settings.showWatermark,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(showWatermark: value))),
                          ],
                        ),
                        _Section(
                          icon: Icons.translate_rounded,
                          title: t.text('language'),
                          children: [
                            _SettingBlock(
                              label: t.text('templateLanguage'),
                              child: _Segmented<AppLanguage>(
                                segments: [
                                  ButtonSegment(
                                      value: AppLanguage.en,
                                      label: Text(t.text('english'))),
                                  ButtonSegment(
                                      value: AppLanguage.hi,
                                      label: Text(t.text('hindi'))),
                                ],
                                selected: settings.language,
                                onChanged: (value) => state.updateSettings(
                                    settings.copyWith(language: value)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section(
      {required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 7),
                Text(title.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1)),
              ],
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 58,
      leading: Icon(icon, color: Colors.white54, size: 21),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF07140C),
        activeTrackColor: AppColors.accentGreen,
        inactiveThumbColor: Colors.white54,
        inactiveTrackColor: Colors.white12,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 64,
      onTap: onTap,
      leading: Icon(icon, color: Colors.white54, size: 21),
      title: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500)),
      subtitle: Text(value,
          style: const TextStyle(color: AppColors.accentGreen, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
    );
  }
}

class _SettingBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final List<ButtonSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const _Segmented(
      {required this.segments,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: {selected},
      showSelectedIcon: true,
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.accentGreen
                : Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFF06130C)
                : Colors.white70),
        side: WidgetStateProperty.all(
            BorderSide(color: Colors.white.withValues(alpha: 0.14))),
        textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
