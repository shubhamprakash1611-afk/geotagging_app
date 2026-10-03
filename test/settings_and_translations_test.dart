import 'package:flutter_test/flutter_test.dart';
import 'package:geotagging_app/models/settings_data.dart';
import 'package:geotagging_app/utils/app_translations.dart';

void main() {
  group('template language', () {
    test('Hindi selection translates template copy', () {
      const translations = AppTranslations(AppLanguage.hi);

      expect(translations.text('verifiedCheckIn'), 'सत्यापित चेक-इन');
      expect(translations.text('latitude'), 'अक्षांश');
      expect(translations.templateName('scan_location'), 'स्थान स्कैन');
      expect(translations.localeName, 'hi_IN');
    });

    test('English is used as a safe fallback', () {
      const translations = AppTranslations(AppLanguage.en);

      expect(translations.text('photo'), 'PHOTO');
      expect(translations.text('missing-key'), 'missing-key');
    });
  });

  test('language survives settings persistence round-trip', () {
    final settings = SettingsData.defaultSettings.copyWith(
      language: AppLanguage.hi,
      activeTemplateId: 'reporting',
    );

    final restored = SettingsData.fromJson(settings.toJson());

    expect(restored.language, AppLanguage.hi);
    expect(restored.activeTemplateId, 'reporting');
  });

  test('capture ratio survives settings persistence round-trip', () {
    final settings = SettingsData.defaultSettings.copyWith(
      captureAspectRatio: CaptureAspectRatio.ratio9x16,
    );

    final restored = SettingsData.fromJson(settings.toJson());

    expect(restored.captureAspectRatio, CaptureAspectRatio.ratio9x16);
  });

  test('legacy settings default to the full sensor 3:4 ratio', () {
    final json = SettingsData.defaultSettings.toJson()
      ..remove('captureAspectRatio');

    final restored = SettingsData.fromJson(json);

    expect(restored.captureAspectRatio, CaptureAspectRatio.ratio4x3);
  });

  test('legacy template identifiers are normalized on load', () {
    final json = SettingsData.defaultSettings.toJson()
      ..['activeTemplateId'] = 'advance_template';

    final restored = SettingsData.fromJson(json);

    expect(restored.activeTemplateId, 'advance');
  });
}
