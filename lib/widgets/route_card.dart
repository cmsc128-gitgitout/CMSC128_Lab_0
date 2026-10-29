import 'package:flutter/material.dart';

import '../models/transit_route.dart';

/// Expandable card for one route. Map button and details are placeholders.
class RouteCard extends StatefulWidget {
  const RouteCard({super.key, required this.route, this.onViewMap});

  final TransitRoute route;
  final VoidCallback? onViewMap;

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;

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
                  route.vehicle.label,
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
                      route.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      route.via,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    Text(
                      route.code,
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
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(4, 8, 12, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Route details coming soon',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
