import 'package:flutter/material.dart';

import '../models/settings_data.dart';
import '../utils/app_translations.dart';
import 'loading_status_card.dart';

class LanguageUpdateCard extends StatelessWidget {
  final AppLanguage language;
  final bool compact;

  const LanguageUpdateCard({
    super.key,
    required this.language,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations(language);

    return LoadingStatusCard(
      icon: Icons.translate_rounded,
      title: t.text('updatingLanguage'),
      subtitle: t.text('localizingAddress'),
      compact: compact,
    );
  }
}
