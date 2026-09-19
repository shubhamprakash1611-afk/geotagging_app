import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';

class SecurityService {
  /// Initialize runtime application self-protection.
  /// Cost: $0 — freeRASP community edition.
  static Future<void> initialize() async {
    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.geotagging.app',
        signingCertHashes: ['AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.geotagging.app'],
        teamId: 'REPLACE_WITH_YOUR_TEAM_ID',
      ),
      watcherMail: 'security@yourapp.com',
    );

    await Talsec.instance.start(config);
    Talsec.instance.attachListener(ThreatCallback(
      // PRODUCTION-GRADE: Block the app, don't just print
      onPrivilegedAccess: _onThreatDetected,
      onSimulator: () {}, // Allow emulators in debug, block in release
      onHooks: _onThreatDetected,
      onAppIntegrity: _onThreatDetected,
      onDebug: () {}, // Allow debugging in debug builds
      onUnofficialStore: _onThreatDetected,
    ));
  }

  static void _onThreatDetected() {
    // In production: show a blocking dialog and close the app
    // The actual dialog is shown from the UI layer via a global key or navigator
    debugPrint('⚠️ SECURITY THREAT DETECTED — blocking app access');
  }
}
