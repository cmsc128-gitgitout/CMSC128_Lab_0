import 'package:flutter/material.dart';

// Expandable card for one route. All texts are empty until data is wired in.
class RouteCard extends StatefulWidget {
  const RouteCard({
    super.key,
    this.badge = '',
    this.title = '',
    this.via = '',
    this.code = '',
    this.onViewMap,
  });

  final String badge; // vehicle label, e.g. JEEP / E-BUS
  final String title; // e.g. route name
  final String via;
  final String code;
  final VoidCallback? onViewMap;

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _expanded = false;

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
                ? const SizedBox(height: 48, width: double.infinity)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}