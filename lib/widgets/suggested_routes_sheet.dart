import 'package:flutter/material.dart';

import '../models/trip_option.dart';
import '../utils/trip_colors.dart';

class SuggestedRoutesSheet extends StatefulWidget {
  const SuggestedRoutesSheet({
    super.key,
    required this.options,
    required this.onSelected,
  });

  final List<TripOption> options; // must not be empty (the screen checks)
  final ValueChanged<TripOption> onSelected;

  @override
  State<SuggestedRoutesSheet> createState() => _SuggestedRoutesSheetState();
}

class _SuggestedRoutesSheetState extends State<SuggestedRoutesSheet> {
  static const _sortOptions = ['Fastest', 'Cheapest', 'Fewest Transfers'];

  int _selectedSort = 0;

  int _byTime(TripOption a, TripOption b) =>
      a.durationMinutes.compareTo(b.durationMinutes);

  List<TripOption> get _sortedOptions {
    final list = List<TripOption>.of(widget.options);
    switch (_selectedSort) {
      case 1: // Cheapest: fare, ties by duration
        list.sort((a, b) {
          final c = a.fare.compareTo(b.fare);
          return c != 0 ? c : _byTime(a, b);
        });
      case 2: // Fewest transfers: transfers, ties by duration
        list.sort((a, b) {
          final c = a.transfers.compareTo(b.transfers);
          return c != 0 ? c : _byTime(a, b);
        });
      default: // Fastest: duration, ties by transfers (matches the finder)
        list.sort((a, b) {
          final c = _byTime(a, b);
          return c != 0 ? c : a.transfers.compareTo(b.transfers);
        });
    }
    return list;
  }

  void _changeSort(int index) {
    if (index == _selectedSort) return;
    setState(() => _selectedSort = index);
  }

  void _select(TripOption option) => widget.onSelected(option);

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedOptions;

    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.32,
      maxChildSize: 0.86,
      snap: true,
      snapSizes: const [0.50, 0.86],
      builder: (context, scrollController) {
        return Material(
          color: const Color(0xFFF7F9FC),
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
                        onTap: () => _changeSort(i),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              for (final option in sorted)
                _RouteOptionCard(
                  option: option,
                  color: tripColor(widget.options.indexOf(option)),
                  onTap: () => _select(option),
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
    required this.option,
    required this.color,
    required this.onTap,
  });

  final TripOption option;
  final Color color; // accent stripe, matches the line on the map
  final VoidCallback onTap;

  String _peso(double v) =>
      '₱${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // Km is hidden when the data has no length_km (distance would be 0).
    final details = [
      if (option.distanceKm > 0) '${option.distanceKm.toStringAsFixed(1)} km',
      '${option.transfers} transfers',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFEEF3F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFD6E0E9)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: color,
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
                              '${option.durationMinutes} min',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _peso(option.fare),
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
                          details,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475467),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _RouteLegs(legs: option.legs),
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

  final List<TripLeg> legs;

  static const _rideColor = Color(0xFF1261A6);

  String _label(TripLeg leg) =>
      leg.modeName.isEmpty ? leg.routeNo : '${leg.modeName}, ${leg.routeNo}';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < legs.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _rideColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _label(legs[i]),
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