import 'package:flutter/material.dart';

import '../../models/location_data.dart';
import '../../models/settings_data.dart';
import '../../utils/app_translations.dart';
import '../../utils/constants.dart';

class ClassicTemplate extends StatelessWidget {
  final LocationData loc;
  final SettingsData settings;

  const ClassicTemplate({super.key, required this.loc, required this.settings});

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(settings.language);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
      decoration: BoxDecoration(
        color: const Color(0xDD111827),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
            left: BorderSide(color: AppColors.accentGreen, width: 5)),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.accentGreen, size: 21),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${loc.city.isNotEmpty ? '${loc.city}, ' : ''}${loc.country} ${loc.flagEmoji}'
                      .trim(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(loc.fullAddress,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 7),
          Wrap(
            spacing: 12,
            runSpacing: 3,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '${loc.latitude.toStringAsFixed(6)}°, ${loc.longitude.toStringAsFixed(6)}°',
                style: const TextStyle(color: Colors.white60, fontSize: 10.5),
              ),
              Text(
                t.format(loc.timestamp, 'dd MMM yyyy • hh:mm a'),
                style: const TextStyle(color: Colors.white60, fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
