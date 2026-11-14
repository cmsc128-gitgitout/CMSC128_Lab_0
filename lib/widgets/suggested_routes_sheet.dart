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
      color: Color(0xFFF5C518),
    ),
    _SuggestedRoute(
      durationMinutes: 20,
      distanceKm: 7.4,
      transfers: 2,
      fare: 39,
      legs: ['Walk', 'Jeep', 'E-bus', 'Walk'],
      color: Color(0xFF65D957),
    ),
    _SuggestedRoute(
      durationMinutes: 25,
      distanceKm: 8.1,
      transfers: 0,
      fare: 45,
      legs: ['Walk', 'Jeep', 'Walk'],
      color: Color(0xFFB05AFF),
    ),
  ];

  static const _sortOptions = ['Fastest', 'Cheapest', 'Fewest Transfers'];

  int _selectedSort = 0;
  _SuggestedRoute? _selectedRoute; // null = highlight the first card

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
    final sorted = _sortedRoutes;
    final selected = _selectedRoute ?? sorted.first;

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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < _sortOptions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _SortOption(
                        label: _sortOptions[i],
                        selected: _selectedSort == i,
                        onTap: () => setState(() {
                          _selectedSort = i;
                          _selectedRoute = null;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              for (final route in sorted)
                _RouteOptionCard(
                  route: route,
                  selected: identical(route, selected),
                  onTap: () => setState(() => _selectedRoute = route),
                ),
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
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 32,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
  const _RouteOptionCard({
    required this.route,
    required this.selected,
    required this.onTap,
  });

  final _SuggestedRoute route;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xFFE3F0FD) : const Color(0xFFEEF3F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? const Color(0xFF1261A6) : const Color(0xFFD6E0E9),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            // IntrinsicHeight is required: a Row with `stretch` inside a
            // ListView has unbounded height and would otherwise collapse/throw.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: route.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${route.durationMinutes} min',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₱${route.fare}',
                              style: const TextStyle(
                                color: Color(0xFF1261A6),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Color(0xFF667085),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${route.distanceKm.toStringAsFixed(1)} km · '
                          '${route.transfers} transfers',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475467),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _RouteLegs(legs: route.legs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteLegs extends StatelessWidget {
  const _RouteLegs({required this.legs});

  final List<String> legs;

  static const _walkColor = Color(0xFFB4BBC6);
  static const _rideColor = Color(0xFF1261A6);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < legs.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            flex: legs[i] == 'Walk' ? 1 : 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explicit width/height + DecoratedBox so the bar always
                // paints, even inside loose Column constraints.
                SizedBox(
                  width: double.infinity,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: legs[i] == 'Walk' ? _walkColor : _rideColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  legs[i],
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475467),
                  ),
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
    required this.color,
  });

  final int durationMinutes;
  final double distanceKm;
  final int transfers;
  final int fare;
  final List<String> legs;
  final Color color; // accent stripe on the left of the card
}