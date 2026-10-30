import 'package:flutter/material.dart';
import 'route_mini_map.dart';

// Expandable card for one route. Fares show "TBD" when no fare is given.
class RouteCard extends StatefulWidget {
  const RouteCard({
    super.key,
    this.badge = '',
    this.title = '',
    this.via = '',
    this.code = '',
    this.regularFare,
    this.discountedFare,
    this.dropOffs = const [],
    this.onViewMap,
    this.startLat, // start point of the route (first stop)
    this.startLng,
    this.endLat, // end point of the route (last stop)
    this.endLng,
  });

  final String badge; // vehicle label, e.g. JEEP / E-BUS
  final String title; // e.g. route name
  final String via;
  final String code;
  final double? regularFare; // empty = show TBD
  final double? discountedFare; // empty = show TBD
  final List<String> dropOffs; // names of the stops after the first
  final double? startLat; // empty = no map shown
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final VoidCallback? onViewMap;

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _expanded = false;

  // True only when all four coordinates were given.
  bool get _hasMap =>
      widget.startLat != null &&
      widget.startLng != null &&
      widget.endLat != null &&
      widget.endLng != null;

  // The map plus the "view full route details" text.
  Widget _buildMap() {
    // No coordinates (e.g. terminal cards): show nothing.
    if (!_hasMap) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        children: [
          // RouteMiniMap already handles its own size and rounded corners.
          RouteMiniMap(
            startLat: widget.startLat!, // "!" = I know it's not empty
            startLng: widget.startLng!,
            endLat: widget.endLat!,
            endLng: widget.endLng!,
          ),
          const SizedBox(height: 6),
          // Tapping it does the same as the map icon for now.
          GestureDetector(
            onTap: widget.onViewMap,
            child: const Text(
              'view full route details',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black54,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final shown = widget.dropOffs.take(2).toList();
    final extra = widget.dropOffs.length - shown.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fare Breakdown',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.regularFare == null
                      ? 'Regular: TBD'
                      : 'Regular: ₱${widget.regularFare!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  widget.discountedFare == null
                      ? 'Discounted: TBD'
                      : 'Discounted: ₱${widget.discountedFare!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Drop-off points',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                for (final name in shown)
                  Text(name, style: const TextStyle(fontSize: 12)),
                if (extra > 0)
                  Text(
                    '+ $extra more',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
              ],
            ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEDED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.badge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.via,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      widget.code,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View on map',
                icon: const Icon(Icons.map_outlined),
                onPressed: widget.onViewMap,
              ),
              IconButton(
                tooltip: _expanded ? 'Hide details' : 'Show details',
                icon: Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(children: [_buildDetails(), _buildMap()])
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}