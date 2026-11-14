import 'package:flutter/material.dart';

class SuggestedRoutesSheet extends StatefulWidget {
  const SuggestedRoutesSheet({super.key});

  @override
  State<SuggestedRoutesSheet> createState() => _SuggestedRoutesSheetState();
}

class _SuggestedRoutesSheetState extends State<SuggestedRoutesSheet> {
  static const _routes = [
    _SuggestedRoute(
      durationMinutes: 15,
      distanceKm: 6.2,
      transfers: 0,
      fare: 19,
      legs: ['Walk', 'Jeep', 'Walk'],
    ),
    _SuggestedRoute(
      durationMinutes: 20,
      distanceKm: 7.4,
      transfers: 2,
      fare: 39,
      legs: ['Walk', 'Jeep', 'E-bus', 'Walk'],
    ),
    _SuggestedRoute(
      durationMinutes: 25,
      distanceKm: 8.1,
      transfers: 0,
      fare: 45,
      legs: ['Walk', 'Jeep', 'Walk'],
    ),
  ];

  static const _sortOptions = ['Fastest', 'Cheapest', 'Fewest Transfers'];

  int _selectedSort = 0;

  List<_SuggestedRoute> get _sortedRoutes {
    final routes = List<_SuggestedRoute>.of(_routes);
    switch (_selectedSort) {
      case 1:
        routes.sort((a, b) => a.fare.compareTo(b.fare));
      case 2:
        routes.sort((a, b) => a.transfers.compareTo(b.transfers));
      default:
        routes.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
    }
    return routes;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.58,
      minChildSize: 0.32,
      maxChildSize: 0.86,
      snap: true,
      snapSizes: const [0.58, 0.86],
      builder: (context, scrollController) {
        return Material(
          color: const Color(0xFFF7F9FC),
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < _sortOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: _SortOption(
                        label: _sortOptions[i],
                        selected: _selectedSort == i,
                        onTap: () => setState(() => _selectedSort = i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              for (final route in _sortedRoutes) _RouteOptionCard(route: route),
            ],
          ),
        );
      },
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF1261A6) : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? const Color(0xFF1261A6) : const Color(0xFFDDE3EA),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 30,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteOptionCard extends StatelessWidget {
  const _RouteOptionCard({required this.route});

  final _SuggestedRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(9, 7, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        border: Border.all(color: const Color(0xFFD6E0E9)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: route.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${route.durationMinutes} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₱${route.fare}',
                      style: const TextStyle(
                        color: Color(0xFF1261A6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF667085),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${route.distanceKm.toStringAsFixed(1)} km · '
                  '${route.transfers} transfers',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF475467)),
                ),
                const SizedBox(height: 4),
                _RouteLegs(legs: route.legs, color: route.color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteLegs extends StatelessWidget {
  const _RouteLegs({required this.legs, required this.color});

  final List<String> legs;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < legs.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            flex: legs[i] == 'Jeep' || legs[i] == 'E-bus' ? 3 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: legs[i] == 'Walk' ? const Color(0xFF98A2B3) : color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  legs[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8, color: Color(0xFF475467)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestedRoute {
  const _SuggestedRoute({
    required this.durationMinutes,
    required this.distanceKm,
    required this.transfers,
    required this.fare,
    required this.legs,
  });

  final int durationMinutes;
  final double distanceKm;
  final int transfers;
  final int fare;
  final List<String> legs;

  Color get color {
    switch (durationMinutes) {
      case 15:
        return const Color(0xFF1683E8);
      case 20:
        return const Color(0xFF65D957);
      default:
        return const Color(0xFFB05AFF);
    }
  }
}
