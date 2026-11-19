import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tara_larga/widgets/location_access_dialog.dart';

void main() {
  Future<void> pumpDialog(
    WidgetTester tester, {
    required Future<void> Function() onAllow,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => LocationAccessDialog(onAllow: onAllow),
              ),
              child: const Text('Open dialog'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows location access copy and allow button', (
    WidgetTester tester,
  ) async {
    await pumpDialog(tester, onAllow: () async {});

    expect(
      find.text("Allow Tara Larga to access this device's location?"),
      findsOneWidget,
    );
    expect(
      find.text(
        'Use your location as your starting point for accurate directions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Allow location access'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('allow invokes the permission request and dismisses the dialog', (
    WidgetTester tester,
  ) async {
    var permissionRequested = false;
    await pumpDialog(tester, onAllow: () async => permissionRequested = true);
    await tester.tap(find.text('Allow location access'));
    await tester.pumpAndSettle();

    expect(permissionRequested, isTrue);
    expect(find.byType(LocationAccessDialog), findsNothing);
  });

  testWidgets('not now dismisses without requesting permission', (
    WidgetTester tester,
  ) async {
    var permissionRequested = false;
    await pumpDialog(tester, onAllow: () async => permissionRequested = true);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(permissionRequested, isFalse);
    expect(find.byType(LocationAccessDialog), findsNothing);
  });
}
