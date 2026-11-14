import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transit_provider.dart';
import '../models/boarding_point.dart';
import '../utils/transport_labels.dart';
import '../widgets/route_card.dart';
import '../models/transit_route.dart';

// Network tab: routes and terminals.
class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  static const _tabs = ['Routes', 'Terminals'];

  int _tab = 0;
  int _filter = 0; // UI-only for now

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Data is loaded at startup in main.dart; the screen only watches it.
    final provider = context.watch<TransitProvider>();
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Blue header extends under the status bar, like the design.
          Container(
            color: const Color(0xFF1261A6),
            padding: EdgeInsets.fromLTRB(22, topInset + 24, 22, 22),
            child: const Text(
              'Routes & Terminals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 10),
                  _buildFilters(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildBody(provider)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _tab = i;
                  _filter = 0;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i
                        ? const Color(0xFF1261A6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      color: _tab == i ? Colors.white : const Color(0xFF245A88),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: Color(0xFFD5E3F0))),
      child: SizedBox(
        height: 44,
        child: TextField(
          onTap: () => _toast('TODO: open route search'),
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Search destination, route, or stop',
            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF667085)),
            prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF1261A6)),
            prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 44),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = _tab == 0
        ? const ['All routes', 'Jeepney', 'E-bus']
        : const ['All terminals', 'Jeepney', 'E-bus'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Material(
              color: _filter == i ? const Color(0xFF1261A6) : Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: _filter == i
                      ? const Color(0xFF1261A6)
                      : const Color(0xFFD5E3F0),
                ),
              ),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => setState(() => _filter = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    filters[i],
                    style: TextStyle(
                      color: _filter == i ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Order matters: loading, then error, then the tab content.
  Widget _buildBody(TransitProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed:
                  provider.load, // the only place the screen calls load()
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    return _tab == 0 ? _buildRoutes(provider) : _buildTerminals(provider);
  }

  Widget _buildRoutes(TransitProvider provider) {
    final routes = provider.routes;
    if (routes.isEmpty) {
      return const Center(child: Text('No routes found'));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _sectionTitle('CITY ROUTES'),
        for (var i = 0; i < routes.length; i++)
          _routeCard(provider, routes[i], initiallyExpanded: i == 0),
      ],
    );
  }

  Widget _routeCard(
    TransitProvider provider,
    TransitRoute r, {
    required bool initiallyExpanded,
  }) {
    // Map points: first stop = start, last stop = end.
    // Fewer than 2 stops (or unknown ids) means no map.
    final first = r.stopIds.length >= 2
        ? provider.stopById(r.stopIds.first)
        : null;
    final last = r.stopIds.length >= 2
        ? provider.stopById(r.stopIds.last)
        : null;
    final hasMap = first != null && last != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RouteCard(
        key: ValueKey(r.id), // keeps expand/collapse state on the right card
        initiallyExpanded: initiallyExpanded,
        badge: transportBadge(provider.modeName(r.transportModeId)),
        title: r.name,
        via: '', // no "via" field in the data yet -> e.g. 'CPU Jeep'
        travelTime: '', // no travel time in the data yet -> e.g. '~35 min'
        // Fares stay null (shows "TBD") until fare_rules arrive (sprint 2):
        // discountedFare: ..., regularFare: ...,
        dropOffs: r.stopIds.skip(1).map<String>(provider.stopName).toList(),
        startLat: hasMap ? first.lat : null,
        startLng: hasMap ? first.lng : null,
        endLat: hasMap ? last.lat : null,
        endLng: hasMap ? last.lng : null,
        onViewMap: () => _toast('TODO: show route on map'),
      ),
    );
  }

  Widget _buildTerminals(TransitProvider provider) {
    final terminals = provider.terminals;
    if (terminals.isEmpty) {
      return const Center(child: Text('No terminals found'));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _sectionTitle('MAJOR TERMINALS'),
        for (var i = 0; i < terminals.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TerminalCard(
              key: ValueKey(terminals[i].id),
              terminal: terminals[i],
              services: provider.modeNamesServing(terminals[i].id),
              initiallyExpanded: i == 0,
              // Hook these up once BoardingPoint has the fields, e.g.
              // subtitle: terminals[i].district,
              // address: terminals[i].address,
              // hours: terminals[i].hours,
              onDetails: () => _toast('TODO: show terminal details'),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF667085),
        ),
      ),
    );
  }
}

class _TerminalCard extends StatefulWidget {
  const _TerminalCard({
    super.key,
    required this.terminal,
    required this.services,
    required this.initiallyExpanded,
    required this.onDetails,
    this.subtitle,
    this.address,
    this.hours,
  });

  final BoardingPoint terminal;
  final List<String> services;
  final bool initiallyExpanded;
  final VoidCallback onDetails;
  final String? subtitle; // e.g. "Villa Arevalo District"
  final String? address; // e.g. "Mohon Terminal, Arevalo, Iloilo City"
  final String? hours; // e.g. "8:00 AM – 11:00 PM · Mon–Fri"

  @override
  State<_TerminalCard> createState() => _TerminalCardState();
}

class _TerminalCardState extends State<_TerminalCard> {
  late bool _expanded = widget.initiallyExpanded;

  // Header subtitle: district if known, otherwise the services.
  String get _subtitle {
    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) {
      return widget.subtitle!;
    }
    return widget.services.isEmpty ? 'Terminal' : widget.services.join(' / ');
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1261A6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5)),
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
        // Blue border when open, soft grey when collapsed (as in the design).
        border: Border.all(
          color: _expanded ? const Color(0xFF9CC4E6) : const Color(0xFFE6EBF0),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      color: Color(0xFFB87900),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.terminal.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE8EDF2)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.address != null)
                    _infoRow(Icons.location_on_outlined, widget.address!),
                  if (widget.hours != null)
                    _infoRow(Icons.access_time, widget.hours!),
                  if (widget.services.isNotEmpty)
                    _infoRow(
                      Icons.directions_bus_outlined,
                      widget.services.join('  ·  '),
                    ),
                  const SizedBox(height: 4),
                  const _TerminalMapPlaceholder(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: widget.onDetails,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1261A6),
                        side: const BorderSide(color: Color(0xFF75A9D7)),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'View terminal details',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Placeholder for the terminal map (grey-green tile with roads and a red pin).
// Swap this for the real map widget later.
class _TerminalMapPlaceholder extends StatelessWidget {
  const _TerminalMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 112,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _PlaceholderMapPainter()),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Icon(
                Icons.location_on,
                color: Color(0xFFD92D20),
                size: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE3ECE5),
    );
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.22, 0),
      Offset(size.width * 0.30, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, 0),
      Offset(size.width * 0.76, size.height),
      road,
    );
    final curve = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.40,
        size.width,
        size.height * 0.58,
      );
    canvas.drawPath(curve, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}