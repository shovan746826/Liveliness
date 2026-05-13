// integration_test/liveness_integration_test.dart
// Basic integration smoke-test. Run on a real device:
//   flutter test integration_test/liveness_integration_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:face_liveness_kyc/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Face Liveness KYC — Integration', () {
    testWidgets('Intro screen renders and Get Started button exists',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Intro screen should be visible
      expect(find.text('Set Up\nFace Verification'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Navigates to liveness screen on Get Started tap',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Liveness screen should now be visible
      expect(find.text('Face Verification'), findsOneWidget);
    });
  });
}
