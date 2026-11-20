import 'package:flutter/material.dart';

import '../models/trip_option.dart';

const _blue = Color(0xFF1261A6);
const _jeepneyBadgeBlue = Color(0xFF101BFF);

class RouteDetailsSheet extends StatelessWidget {
  const RouteDetailsSheet({
    super.key,
    required this.option,
    required this.onStart,
  });

  final TripOption option;
  final VoidCallback onStart;

  String _peso(double value) =>
      '₱${value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final summary = [
      if (option.distanceKm > 0) '${option.distanceKm.toStringAsFixed(1)} km',
      '${option.transfers} transfers',
    ].join(' · ');

    return Material(
      color: const Color(0xFFFFFFFF),
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${option.durationMinutes} min',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              summary,
                              style: const TextStyle(
                                fontSize: 11,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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

  String _distanceText() {
    if (leg.distanceKm <= 0) return '';
    final meters = leg.distanceKm * 1000;
    return meters >= 1000
        ? '${leg.distanceKm.toStringAsFixed(1)} km'
        : '${meters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final mode = leg.modeName.isEmpty ? 'Transit' : leg.modeName;
    final distance = _distanceText();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE2EAF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: _jeepneyBadgeBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus_filled,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$mode to ${leg.to.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    Text(
                      fare,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${leg.minutes} min ride',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (distance.isNotEmpty)
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                          height: 1.15,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                _StopDetail(label: 'SAKAY DIRI', stopName: leg.from.name),
                _StopDetail(label: 'NAOG DIRI', stopName: leg.to.name),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StopDetail extends StatelessWidget {
  const _StopDetail({required this.label, required this.stopName});

  final String label;
  final String stopName;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF344054),
          height: 1.15,
        ),
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: stopName),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TransferPoint extends StatelessWidget {
  const _TransferPoint({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.transfer_within_a_station,
            size: 14,
            color: Color(0xFF667085),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'Transfer at $name',
              style: const TextStyle(
                fontSize: 10,
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
