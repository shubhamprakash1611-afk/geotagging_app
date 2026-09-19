import 'dart:math';

/// Generates Open Location Codes (Plus Codes) from lat/lon coordinates.
/// Reference: https://github.com/google/open-location-code
class PlusCodeGenerator {
  static const String _alphabet = '23456789CFGHJMPQRVWX';
  static const int _pairCodeLength = 10;
  static const double _gridSizeDegrees = 0.000125;

  /// Encode lat/lon into a Plus Code string (e.g., "87G8Q2PQ+VX")
  static String encode(double latitude, double longitude, {int codeLength = 10}) {
    // Clamp values
    latitude = latitude.clamp(-90.0, 90.0);
    longitude = _normalizeLongitude(longitude);

    // Adjust latitude if it's at the max
    if (latitude == 90.0) latitude -= _computePrecision(codeLength);

    StringBuffer code = StringBuffer();
    double latVal = latitude + 90.0;
    double lonVal = longitude + 180.0;

    int digitCount = 0;
    double latPlaceVal = 400.0;
    double lonPlaceVal = 400.0;

    while (digitCount < codeLength) {
      if (digitCount < _pairCodeLength) {
        // Pair encoding
        latPlaceVal /= 20.0;
        lonPlaceVal /= 20.0;

        int latDigit = (latVal / latPlaceVal).floor();
        int lonDigit = (lonVal / lonPlaceVal).floor();

        latVal -= latDigit * latPlaceVal;
        lonVal -= lonDigit * lonPlaceVal;

        code.write(_alphabet[latDigit]);
        code.write(_alphabet[lonDigit]);
        digitCount += 2;

        if (digitCount == 8) code.write('+');
      } else {
        // Grid encoding for higher precision
        latPlaceVal /= 5.0;
        lonPlaceVal /= 4.0;

        int row = (latVal / latPlaceVal).floor();
        int col = (lonVal / lonPlaceVal).floor();

        latVal -= row * latPlaceVal;
        lonVal -= col * lonPlaceVal;

        code.write(_alphabet[row * 4 + col]);
        digitCount += 1;
      }
    }

    // Pad short codes
    while (code.length < 9) {
      code.write('0');
      if (code.length == 8) code.write('+');
    }

    if (!code.toString().contains('+')) code.write('+');

    return code.toString();
  }

  static double _normalizeLongitude(double lon) {
    while (lon < -180) lon += 360;
    while (lon >= 180) lon -= 360;
    return lon;
  }

  static double _computePrecision(int codeLength) {
    if (codeLength <= _pairCodeLength) {
      return pow(20, (codeLength ~/ -2) + 2).toDouble();
    }
    return pow(20, -3).toDouble() / pow(5, codeLength - _pairCodeLength);
  }
}
