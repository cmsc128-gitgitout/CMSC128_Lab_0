import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tara_larga/widgets/location_access_dialog.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const LocationAccessDialog(),
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
    await pumpDialog(tester);

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

  testWidgets('allow and not now dismiss the dialog', (
    WidgetTester tester,
  ) async {
    for (final buttonLabel in ['Allow location access', 'Not now']) {
      await pumpDialog(tester);
      await tester.tap(find.text(buttonLabel));
      await tester.pumpAndSettle();

      expect(find.byType(LocationAccessDialog), findsNothing);
    }
  });
}
