import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/settings_data.dart';
import '../../utils/app_translations.dart';
import '../../utils/constants.dart';

class DateTimeTemplate extends StatelessWidget {
  final LocationData loc;
  final SettingsData settings;

  const DateTimeTemplate(
      {super.key, required this.loc, required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    t.format(loc.timestamp, 'hh:mm'),
                    style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1),
                  ),
                ),
                Text(t.format(loc.timestamp, 'a'),
                    style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
              width: 3,
              height: 68,
              decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    t.format(loc.timestamp, 'dd MMMM yyyy • EEEE'),
                    style: const TextStyle(
                        color: Color(0xFF052E16),
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'
                      .trim(),
                  style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(loc.fullAddress,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${t.text('latitude')} ${loc.latitude.toStringAsFixed(6)}°  ${t.text('longitude')} ${loc.longitude.toStringAsFixed(6)}°',
                  style:
                      const TextStyle(color: Color(0xFF6B7280), fontSize: 9.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
