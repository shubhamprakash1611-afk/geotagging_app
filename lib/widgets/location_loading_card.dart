import 'package:flutter/material.dart';

import '../models/settings_data.dart';
import '../utils/app_translations.dart';
import 'loading_status_card.dart';

class LocationLoadingCard extends StatelessWidget {
  final AppLanguage language;
  final bool compact;

  const LocationLoadingCard({
    super.key,
    required this.language,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(language);
    return LoadingStatusCard(
      icon: Icons.my_location_rounded,
      title: t.text('fetchingLocation'),
      subtitle: t.text('findingAddress'),
      compact: compact,
    );
  }
}
