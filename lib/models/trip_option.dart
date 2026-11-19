import 'boarding_point.dart';

// One ride on a single route, from one boarding point to another.
class TripLeg {
  const TripLeg({
    required this.routeNo,
    required this.routeName,
    required this.modeName,
    required this.from,
    required this.to,
    required this.minutes,
    required this.distanceKm,
    required this.fare,
    required this.path,
  });

  final String routeNo; // e.g. JR10
  final String routeName;
  final String modeName; // e.g. Jeepney ('' if unknown)
  final BoardingPoint from;
  final BoardingPoint to;
  final int minutes;
  final double distanceKm;
  final double fare;
  final List<List<double>> path; // [lng, lat], only the part this leg rides
}

// One suggested way to get from the start to the destination.
// 1 leg = direct, 2+ legs = with transfers.
class TripOption {
  const TripOption({
    required this.legs,
    required this.durationMinutes,
    required this.fare,
    required this.studentFare,
  });

  final List<TripLeg> legs;
  final int durationMinutes; // rides + estimated wait at each transfer
  final double fare;
  final double studentFare;

  int get transfers => legs.length - 1;

  double get distanceKm => legs.fold(0.0, (sum, l) => sum + l.distanceKm);

  // The whole trip as one line, in [lng, lat] order for Mapbox.
  List<List<double>> get path => [for (final l in legs) ...l.path];
}