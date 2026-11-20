import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tara_larga/models/boarding_point.dart';
import 'package:tara_larga/models/trip_option.dart';
import 'package:tara_larga/widgets/route_details_sheet.dart';

void main() {
  const origin = BoardingPoint(
    id: 'origin',
    name: 'Diversion Road Stop',
    lat: 10.7,
    lng: 122.5,
  );
  const transfer = BoardingPoint(
    id: 'transfer',
    name: 'City Proper',
    lat: 10.7,
    lng: 122.6,
  );
  const destination = BoardingPoint(
    id: 'destination',
    name: 'Jaro Plaza Stop',
    lat: 10.8,
    lng: 122.6,
  );

  testWidgets('renders one transit card per route leg', (tester) async {
    const option = TripOption(
      legs: [
        TripLeg(
          routeNo: 'JR10',
          routeName: 'Jaro',
          modeName: 'Jeepney',
          from: origin,
          to: transfer,
          minutes: 8,
          distanceKm: 0.24,
          fare: 12,
          path: [],
        ),
        TripLeg(
          routeNo: 'CPU1',
          routeName: 'CPU',
          modeName: 'Jeepney',
          from: transfer,
          to: destination,
          minutes: 10,
          distanceKm: 0.2,
          fare: 7,
          path: [],
        ),
      ],
      durationMinutes: 18,
      fare: 19,
      studentFare: 19,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: RouteDetailsSheet(option: option, onStart: () {}),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('route-leg-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('route-leg-1')), findsOneWidget);
    expect(find.text('18 min'), findsOneWidget);
    expect(find.text('Transfer at City Proper'), findsOneWidget);
    expect(find.text('240 m'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            widget.icon == Icons.directions_bus_filled &&
            widget.color == Colors.white,
      ),
      findsNWidgets(2),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().startsWith('SAKAY DIRI'),
      ),
      findsNWidgets(2),
    );

    final title = tester.widget<Text>(find.text('Jeepney to City Proper'));
    expect(title.style?.fontSize, 11);
    expect(title.style?.fontWeight, FontWeight.w700);
  });
}
