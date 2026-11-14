import 'package:flutter/material.dart';

import 'route_mini_map.dart';

// Expandable card for one route. Fares show "TBD" when no fare is given.
class RouteCard extends StatefulWidget {
  const RouteCard({
    super.key,
    this.badge = '',
    this.title = '',
    this.via = '',
    this.travelTime = '',
    this.code = '',
    this.regularFare,
    this.discountedFare,
    this.dropOffs = const [],
    this.onViewMap,
    this.initiallyExpanded = false,
    this.startLat, // start point of the route (first stop)
    this.startLng,
    this.endLat, // end point of the route (last stop)
    this.endLng,
  });

  final String badge; // vehicle label, e.g. JEEP / E-BUS
  final String title; // e.g. route name
  final String via; // e.g. "CPU Jeep" (rendered as "via CPU Jeep")
  final String travelTime; // e.g. "~35 min"
  final String code; // optional extra line (not in the current design)
  final double? regularFare; // null = show TBD
  final double? discountedFare; // shown as the "Student" fare; null = TBD
  final List<String> dropOffs; // names of the stops after the first
  final double? startLat; // null = no map shown
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final VoidCallback? onViewMap;
  final bool initiallyExpanded;

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  late bool _expanded = widget.initiallyExpanded;

  // True only when all four coordinates were given.
  bool get _hasMap =>
      widget.startLat != null &&
      widget.startLng != null &&
      widget.endLat != null &&
      widget.endLng != null;

  // "via CPU Jeep · ~35 min" (skips whichever part is empty)
  String get _subtitle => [
        if (widget.via.isNotEmpty) 'via ${widget.via}',
        if (widget.travelTime.isNotEmpty) widget.travelTime,
      ].join(' · ');

  String get _fareText {
    final fare = widget.discountedFare;
    if (fare == null) return 'TBD';
    return '₱${fare.toStringAsFixed(fare % 1 == 0 ? 0 : 2)}';
  }

  // The map only. RouteMiniMap handles its own size and rounded corners.
  Widget _buildMap() {
    // No coordinates: show nothing.
    if (!_hasMap) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: RouteMiniMap(
        startLat: widget.startLat!,
        startLng: widget.startLng!,
        endLat: widget.endLat!,
        endLng: widget.endLng!,
      ),
    );
  }

  Widget _buildDetails() {
    final shown = widget.dropOffs.take(2).toList();
    final extra = widget.dropOffs.length - shown.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMON STOPS',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          for (final name in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(name, style: const TextStyle(fontSize: 13)),
            ),
          if (extra > 0)
            Text(
              '+ $extra more',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        // Blue border when open, soft grey when collapsed (as in the design).
        border: Border.all(
          color: _expanded ? const Color(0xFF9CC4E6) : const Color(0xFFE6EBF0),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F1FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_bus_outlined,
                      color: Color(0xFF1261A6),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (_subtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                        if (widget.code.isNotEmpty)
                          Text(
                            widget.code,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF667085),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Student fare, top right.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _fareText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1261A6),
                        ),
                      ),
                      const Text(
                        'Student',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF1261A6),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFE8EDF2)),
                      _buildDetails(),
                      _buildMap(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: widget.onViewMap,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1261A6),
                                    side: const BorderSide(
                                      color: Color(0xFF75A9D7),
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text('Show on map'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: FilledButton(
                                  onPressed: widget.onViewMap,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1261A6),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: const Text('Full route'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}