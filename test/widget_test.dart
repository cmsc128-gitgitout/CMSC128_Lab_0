// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tara_larga/main.dart';
import 'package:tara_larga/screens/title_screen.dart';

void main() {
  testWidgets('Splash screen displays the uploaded background and logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaraLargaApp());

    expect(find.byType(TitleScreen), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/title_screen_bg.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/tara_larga_logo.png',
      ),
      findsOneWidget,
    );
  });
}
