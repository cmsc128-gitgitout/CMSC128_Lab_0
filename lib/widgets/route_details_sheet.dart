import 'package:flutter/material.dart';

import '../models/boarding_point.dart';
import '../models/trip_option.dart';

class RouteDetailsSheet extends StatelessWidget {
  const RouteDetailsSheet({
    super.key,
    required this.option,
    required this.origin,
    required this.destination,
    required this.onStart,
  });

  final TripOption option;
  final BoardingPoint origin;
  final BoardingPoint destination;
  final VoidCallback onStart;

  static const _blue = Color(0xFF1261A6);

  String _peso(double value) =>
      '₱${value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final summary = [
      if (option.distanceKm > 0) '${option.distanceKm.toStringAsFixed(1)} km',
      '${option.transfers} transfers',
    ].join(' · ');

    return Material(
      color: const Color(0xFFF7F9FC),
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4D9E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${option.durationMinutes} min',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              summary,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475467),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _peso(option.fare),
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          origin.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF667085),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          destination.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8EF)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                children: [
                  for (var index = 0; index < option.legs.length; index++) ...[
                    if (index > 0)
                      _TransferPoint(name: option.legs[index - 1].to.name),
                    _TripLegCard(
                      key: ValueKey('route-leg-$index'),
                      leg: option.legs[index],
                      fare: _peso(option.legs[index].fare),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripLegCard extends StatelessWidget {
  const _TripLegCard({super.key, required this.leg, required this.fare});

  final TripLeg leg;
  final String fare;

  @override
  Widget build(BuildContext context) {
    final mode = leg.modeName.isEmpty ? 'Transit' : leg.modeName;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.directions_bus_filled,
              size: 19,
              color: Color(0xFF1261A6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$mode to ${leg.to.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${leg.routeNo} · ${leg.minutes} min',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475467),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${leg.from.name}  →  ${leg.to.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            fare,
            style: const TextStyle(
              color: Color(0xFF1261A6),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPoint extends StatelessWidget {
  const _TransferPoint({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.transfer_within_a_station,
            size: 16,
            color: Color(0xFF667085),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Transfer at $name',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
