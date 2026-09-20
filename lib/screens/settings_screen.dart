import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/settings_data.dart';
import '../utils/constants.dart';
import 'template_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        final settings = state.settings;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildSectionHeader('GeoTag Overlay'),
                    SwitchListTile(
                      title: const Text('Show GeoTag', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.geoTagEnabled,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(geoTagEnabled: val));
                      },
                    ),
                    if (settings.geoTagEnabled) ...[
                      ListTile(
                        title: const Text('Placement', style: TextStyle(color: Colors.white)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SegmentedButton<GeoTagPlacement>(
                            segments: const [
                              ButtonSegment(value: GeoTagPlacement.top, label: Text('Top')),
                              ButtonSegment(value: GeoTagPlacement.bottom, label: Text('Bottom')),
                            ],
                            selected: {settings.geoTagPlacement},
                            onSelectionChanged: (Set<GeoTagPlacement> newSelection) {
                              state.updateSettings(settings.copyWith(geoTagPlacement: newSelection.first));
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) return AppColors.accentGreen;
                                  return Colors.transparent;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Active Template', style: TextStyle(color: Colors.white)),
                        subtitle: Text(settings.activeTemplateId, style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TemplateScreen()),
                          );
                        },
                      ),
                    ],

                    _buildSectionHeader('Camera'),
                    ListTile(
                      title: const Text('Image Resolution', style: TextStyle(color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SegmentedButton<ImageResolution>(
                          segments: const [
                            ButtonSegment(value: ImageResolution.low, label: Text('Low')),
                            ButtonSegment(value: ImageResolution.medium, label: Text('Med')),
                            ButtonSegment(value: ImageResolution.high, label: Text('High')),
                          ],
                          selected: {settings.imageResolution},
                          onSelectionChanged: (Set<ImageResolution> newSelection) {
                            state.updateSettings(settings.copyWith(imageResolution: newSelection.first));
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) return AppColors.accentGreen;
                                return Colors.transparent;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Shutter Sound', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.shutterSoundEnabled,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(shutterSoundEnabled: val));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Haptic Feedback (Vibrate)', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.hapticFeedbackEnabled,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(hapticFeedbackEnabled: val));
                      },
                    ),

                    _buildSectionHeader('Map & Data'),
                    ListTile(
                      title: const Text('Map Type', style: TextStyle(color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SegmentedButton<MapType>(
                          segments: const [
                            ButtonSegment(value: MapType.street, label: Text('Street')),
                            ButtonSegment(value: MapType.earth, label: Text('Earth')),
                          ],
                          selected: {settings.mapType},
                          onSelectionChanged: (Set<MapType> newSelection) {
                            state.updateSettings(settings.copyWith(mapType: newSelection.first));
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) return AppColors.accentGreen;
                                return Colors.transparent;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Map Zoom Level', style: TextStyle(color: Colors.white)),
                      subtitle: Slider(
                        value: settings.mapZoomLevel,
                        min: 10,
                        max: 18,
                        divisions: 8,
                        activeColor: AppColors.accentGreen,
                        label: settings.mapZoomLevel.toStringAsFixed(0),
                        onChanged: (val) {
                          state.updateSettings(settings.copyWith(mapZoomLevel: val));
                        },
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Show Weather Data', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.showWeatherData,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(showWeatherData: val));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show Sensor Data', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.showSensorData,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(showSensorData: val));
                      },
                    ),

                    _buildSectionHeader('Display'),
                    SwitchListTile(
                      title: const Text('Show Plus Code', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.showPlusCode,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(showPlusCode: val));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Show Watermark', style: TextStyle(color: Colors.white)),
                      activeColor: AppColors.accentGreen,
                      value: settings.showWatermark,
                      onChanged: (val) {
                        state.updateSettings(settings.copyWith(showWatermark: val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accentGreen,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
