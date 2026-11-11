// Unit 8: release checks. Run: flutter test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_fair/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('TODO A2: About shows the version and build number', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'CICT Org Fair',
      packageName: 'org_fair',
      version: '1.1.0',
      buildNumber: '2',
      buildSignature: '',
    );
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Version 1.1.0 (build 2)'), findsOneWidget);
  });
}
