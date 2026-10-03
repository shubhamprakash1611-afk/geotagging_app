import 'package:intl/intl.dart';

import '../models/settings_data.dart';

/// Lightweight app copy used by the camera UI and by the pixels burned into
/// photos. Keeping this independent from [BuildContext] also makes captured
/// templates use the exact language selected in Settings.
class AppTranslations {
  final AppLanguage language;

  const AppTranslations(this.language);

  bool get isHindi => language == AppLanguage.hi;
  String get localeName => isHindi ? 'hi_IN' : 'en_US';

  static const Map<String, Map<AppLanguage, String>> _copy = {
    'fetchingLocation': {
      AppLanguage.en: 'Finding your location',
      AppLanguage.hi: 'आपका स्थान खोजा जा रहा है'
    },
    'findingAddress': {
      AppLanguage.en: 'Getting GPS coordinates and address…',
      AppLanguage.hi: 'GPS निर्देशांक और पता प्राप्त हो रहा है…'
    },
    'updatingLanguage': {
      AppLanguage.en: 'Updating language',
      AppLanguage.hi: 'भाषा अपडेट हो रही है'
    },
    'localizingAddress': {
      AppLanguage.en: 'Localizing your current address…',
      AppLanguage.hi: 'आपके वर्तमान पते का अनुवाद हो रहा है…'
    },
    'settings': {AppLanguage.en: 'Settings', AppLanguage.hi: 'सेटिंग्स'},
    'geotagOverlay': {
      AppLanguage.en: 'GeoTag overlay',
      AppLanguage.hi: 'जियोटैग ओवरले'
    },
    'showGeotag': {
      AppLanguage.en: 'Show GeoTag',
      AppLanguage.hi: 'जियोटैग दिखाएँ'
    },
    'placement': {AppLanguage.en: 'Placement', AppLanguage.hi: 'स्थान'},
    'top': {AppLanguage.en: 'Top', AppLanguage.hi: 'ऊपर'},
    'bottom': {AppLanguage.en: 'Bottom', AppLanguage.hi: 'नीचे'},
    'activeTemplate': {
      AppLanguage.en: 'Active template',
      AppLanguage.hi: 'सक्रिय टेम्पलेट'
    },
    'camera': {AppLanguage.en: 'Camera', AppLanguage.hi: 'कैमरा'},
    'imageResolution': {
      AppLanguage.en: 'Image resolution',
      AppLanguage.hi: 'फ़ोटो रिज़ॉल्यूशन'
    },
    'low': {AppLanguage.en: 'Low', AppLanguage.hi: 'कम'},
    'medium': {AppLanguage.en: 'Medium', AppLanguage.hi: 'मध्यम'},
    'high': {AppLanguage.en: 'High', AppLanguage.hi: 'उच्च'},
    'shutterSound': {
      AppLanguage.en: 'Shutter sound',
      AppLanguage.hi: 'शटर ध्वनि'
    },
    'hapticFeedback': {
      AppLanguage.en: 'Haptic feedback',
      AppLanguage.hi: 'हैप्टिक फ़ीडबैक'
    },
    'mapAndData': {AppLanguage.en: 'Map & data', AppLanguage.hi: 'मैप और डेटा'},
    'mapType': {AppLanguage.en: 'Map type', AppLanguage.hi: 'मैप प्रकार'},
    'street': {AppLanguage.en: 'Street', AppLanguage.hi: 'सड़क'},
    'earth': {AppLanguage.en: 'Satellite', AppLanguage.hi: 'सैटेलाइट'},
    'mapZoom': {AppLanguage.en: 'Map zoom', AppLanguage.hi: 'मैप ज़ूम'},
    'weatherData': {
      AppLanguage.en: 'Show weather data',
      AppLanguage.hi: 'मौसम डेटा दिखाएँ'
    },
    'sensorData': {
      AppLanguage.en: 'Show sensor data',
      AppLanguage.hi: 'सेंसर डेटा दिखाएँ'
    },
    'display': {AppLanguage.en: 'Display', AppLanguage.hi: 'डिस्प्ले'},
    'plusCode': {
      AppLanguage.en: 'Show plus code',
      AppLanguage.hi: 'प्लस कोड दिखाएँ'
    },
    'watermark': {
      AppLanguage.en: 'Show watermark',
      AppLanguage.hi: 'वॉटरमार्क दिखाएँ'
    },
    'language': {AppLanguage.en: 'Language', AppLanguage.hi: 'भाषा'},
    'templateLanguage': {
      AppLanguage.en: 'Template language',
      AppLanguage.hi: 'टेम्पलेट भाषा'
    },
    'english': {AppLanguage.en: 'English', AppLanguage.hi: 'अंग्रेज़ी'},
    'hindi': {AppLanguage.en: 'हिंदी', AppLanguage.hi: 'हिंदी'},
    'template': {AppLanguage.en: 'Templates', AppLanguage.hi: 'टेम्पलेट'},
    'new': {AppLanguage.en: 'NEW', AppLanguage.hi: 'नया'},
    'selected': {AppLanguage.en: 'Selected', AppLanguage.hi: 'चयनित'},
    'tapToUse': {
      AppLanguage.en: 'Tap to use',
      AppLanguage.hi: 'उपयोग करने के लिए टैप करें'
    },
    'locationUnavailable': {
      AppLanguage.en: 'Location unavailable',
      AppLanguage.hi: 'स्थान उपलब्ध नहीं'
    },
    'latitude': {AppLanguage.en: 'Lat', AppLanguage.hi: 'अक्षांश'},
    'longitude': {AppLanguage.en: 'Lon', AppLanguage.hi: 'देशांतर'},
    'note': {AppLanguage.en: 'Note', AppLanguage.hi: 'नोट'},
    'verifiedCheckIn': {
      AppLanguage.en: 'VERIFIED CHECK-IN',
      AppLanguage.hi: 'सत्यापित चेक-इन'
    },
    'navigationCompass': {
      AppLanguage.en: 'Navigation compass',
      AppLanguage.hi: 'नेविगेशन कंपास'
    },
    'facing': {AppLanguage.en: 'Facing', AppLanguage.hi: 'दिशा'},
    'bearing': {
      AppLanguage.en: 'Azimuth / bearing',
      AppLanguage.hi: 'दिगंश / दिशा'
    },
    'north': {AppLanguage.en: 'North', AppLanguage.hi: 'उत्तर'},
    'northEast': {AppLanguage.en: 'North East', AppLanguage.hi: 'उत्तर-पूर्व'},
    'east': {AppLanguage.en: 'East', AppLanguage.hi: 'पूर्व'},
    'southEast': {AppLanguage.en: 'South East', AppLanguage.hi: 'दक्षिण-पूर्व'},
    'south': {AppLanguage.en: 'South', AppLanguage.hi: 'दक्षिण'},
    'southWest': {
      AppLanguage.en: 'South West',
      AppLanguage.hi: 'दक्षिण-पश्चिम'
    },
    'west': {AppLanguage.en: 'West', AppLanguage.hi: 'पश्चिम'},
    'northWest': {AppLanguage.en: 'North West', AppLanguage.hi: 'उत्तर-पश्चिम'},
    'collection': {AppLanguage.en: 'Collection', AppLanguage.hi: 'संग्रह'},
    'mapData': {AppLanguage.en: 'Map data', AppLanguage.hi: 'मैप डेटा'},
    'cameraFlip': {AppLanguage.en: 'Flip', AppLanguage.hi: 'पलटें'},
    'quickShare': {AppLanguage.en: 'QUICK SHARE', AppLanguage.hi: 'तुरंत शेयर'},
    'photo': {AppLanguage.en: 'PHOTO', AppLanguage.hi: 'फ़ोटो'},
    'video': {AppLanguage.en: 'VIDEO', AppLanguage.hi: 'वीडियो'},
  };

  String text(String key) =>
      _copy[key]?[language] ?? _copy[key]?[AppLanguage.en] ?? key;

  String format(DateTime value, String pattern) =>
      DateFormat(pattern, localeName).format(value);

  String templateName(String id) {
    const names = {
      'advance': ['Advanced', 'एडवांस्ड'],
      'advance2': ['Advanced clean', 'एडवांस्ड क्लीन'],
      'datetime': ['Date & time', 'दिनांक और समय'],
      'scan_location': ['Scan location', 'स्थान स्कैन'],
      'classic': ['Classic', 'क्लासिक'],
      'reporting': ['Reporting', 'रिपोर्टिंग'],
      'navigation': ['Navigation compass', 'नेविगेशन कंपास'],
    };
    final value = names[id] ?? [id, id];
    return value[isHindi ? 1 : 0];
  }

  String templateDescription(String id) {
    const descriptions = {
      'advance': [
        'Map, address, coordinates, weather and sensors.',
        'मैप, पता, निर्देशांक, मौसम और सेंसर।'
      ],
      'advance2': [
        'A clean location card without sensor badges.',
        'सेंसर बैज के बिना साफ़ लोकेशन कार्ड।'
      ],
      'datetime': [
        'Prominent time and localized date details.',
        'प्रमुख समय और स्थानीयकृत दिनांक विवरण।'
      ],
      'scan_location': [
        'QR code for opening the captured coordinates.',
        'कैप्चर किए गए निर्देशांक खोलने के लिए QR कोड।'
      ],
      'classic': [
        'A compact, minimal location strip.',
        'एक कॉम्पैक्ट, सरल लोकेशन पट्टी।'
      ],
      'reporting': [
        'A verified check-in card for field reports.',
        'फ़ील्ड रिपोर्ट के लिए सत्यापित चेक-इन कार्ड।'
      ],
      'navigation': [
        'Compass, bearing, altitude and map context.',
        'कंपास, दिशा, ऊँचाई और मैप संदर्भ।'
      ],
    };
    final value = descriptions[id] ?? ['', ''];
    return value[isHindi ? 1 : 0];
  }
}
