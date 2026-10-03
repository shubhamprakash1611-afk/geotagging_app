import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geotagging_app/models/settings_data.dart';
import 'package:geotagging_app/providers/app_state_provider.dart';
import 'package:geotagging_app/widgets/bottom_nav_bar.dart';
import 'package:geotagging_app/widgets/capture_aspect_ratio_selector.dart';
import 'package:geotagging_app/widgets/language_update_card.dart';
import 'package:geotagging_app/widgets/location_loading_card.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('aspect selector exposes all framing choices', (tester) async {
    tester.view.physicalSize = const Size(280, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    CaptureAspectRatio? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2.5),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: CaptureAspectRatioSelector(
              selected: CaptureAspectRatio.ratio4x3,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('3:4'), findsOneWidget);
    expect(find.text('9:16'), findsOneWidget);
    expect(find.text('1:1'), findsOneWidget);
    expect(find.text('Full'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('aspect-square')));
    expect(selected, CaptureAspectRatio.square);
    expect(tester.takeException(), isNull);
  });

  testWidgets('camera controls contain zoom and photo capture only',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = AppStateProvider();
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2.5),
              boldText: true,
            ),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(size: 48),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(
                language: AppLanguage.en,
                onShutterPressed: () {},
                onCollectionPressed: () {},
                onMapDataPressed: () {},
                onCameraFlipPressed: () {},
                onTemplatesPressed: () {},
                onZoomChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('QUICK SHARE'), findsNothing);
    expect(find.text('VIDEO'), findsNothing);
    expect(find.text('1×'), findsOneWidget);
    expect(find.text('2×'), findsOneWidget);
    expect(find.text('3×'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language progress card fits narrow screens in both languages',
      (tester) async {
    tester.view.physicalSize = const Size(280, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final language in AppLanguage.values) {
      for (final card in <Widget>[
        LanguageUpdateCard(language: language, compact: true),
        LocationLoadingCard(language: language, compact: true),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.5),
                boldText: true,
              ),
              child: child!,
            ),
            home: Scaffold(body: Center(child: card)),
          ),
        );

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
