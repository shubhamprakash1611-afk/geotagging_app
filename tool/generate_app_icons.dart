import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const sourcePath = 'assets/images/app_icon_master.png';
  final source = img.decodeImage(File(sourcePath).readAsBytesSync());
  if (source == null) {
    throw StateError('Could not decode $sourcePath');
  }

  void writePng(String path, int size) {
    final output = img.copyResize(
      source,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    final file = File(path)..parent.createSync(recursive: true);
    file.writeAsBytesSync(img.encodePng(output, level: 9));
  }

  void writeAndroidAdaptiveForeground(String path, int size) {
    // Android masks adaptive icons into different launcher shapes. Keeping a
    // little breathing room prevents the artwork from being clipped by round
    // and squircle masks while the white background layer fills the icon.
    const artworkScale = 0.84;
    final artworkSize = (size * artworkScale).round();
    final artwork = img.copyResize(
      source,
      width: artworkSize,
      height: artworkSize,
      interpolation: img.Interpolation.cubic,
    );
    final output = img.Image(width: size, height: size, numChannels: 4);
    img.fill(output, color: img.ColorRgba8(0, 0, 0, 0));
    img.compositeImage(output, artwork, center: true);

    final file = File(path)..parent.createSync(recursive: true);
    file.writeAsBytesSync(img.encodePng(output, level: 9));
  }

  const androidSizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  const androidForegroundSizes = {
    'mdpi': 108,
    'hdpi': 162,
    'xhdpi': 216,
    'xxhdpi': 324,
    'xxxhdpi': 432,
  };
  for (final entry in androidSizes.entries) {
    writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      entry.value,
    );
    writePng(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_round.png',
      entry.value,
    );
  }
  for (final entry in androidForegroundSizes.entries) {
    writeAndroidAdaptiveForeground(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher_foreground.png',
      entry.value,
    );
  }
  writePng('android/app/src/main/res/drawable-nodpi/launch_logo.png', 256);

  const iosIcons = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
  };
  for (final entry in iosIcons.entries) {
    writePng(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}',
      entry.value,
    );
  }

  for (final size in [16, 32, 64, 128, 256, 512, 1024]) {
    writePng(
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png',
      size,
    );
  }

  writePng('web/favicon.png', 32);
  writePng('web/icons/Icon-192.png', 192);
  writePng('web/icons/Icon-512.png', 512);
  writePng('web/icons/Icon-maskable-192.png', 192);
  writePng('web/icons/Icon-maskable-512.png', 512);

  final windowsIcon = img.copyResize(
    source,
    width: 256,
    height: 256,
    interpolation: img.Interpolation.cubic,
  );
  File('windows/runner/resources/app_icon.ico')
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(img.encodeIco(windowsIcon));

  stdout.writeln('Generated platform icons from $sourcePath');
}
