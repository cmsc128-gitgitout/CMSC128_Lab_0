import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transit_provider.dart';
import '../utils/transport_labels.dart';
import '../widgets/pill_toggle.dart';
import '../widgets/route_card.dart';
import '../widgets/search_pill.dart';

// Network tab: routes and terminals.
class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  static const _tabs = ['Routes', 'Terminals'];
  static const _filters = [
    'All Terminals',
    'Jeepney Terminals',
    'Bus Terminals',
  ];

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Routes and Terminals',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              PillToggle(
                labels: _tabs,
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 16),
              SearchPill(
                hint: 'Search destination, route, or stop',
                onTap: () => _toast('TODO: open route search'),
              ),
              const SizedBox(height: 12),
              PillToggle(
                labels: _filters,
                selectedIndex: _filter,
                onChanged: (i) => setState(() => _filter = i),
                selectedColor: const Color(0xFFBDBDBD),
                selectedTextColor: Colors.black,
                fontSize: 12,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        ),
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
              onPressed: provider.load, // the only place the screen calls load()
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
        for (final r in routes) _routeCard(provider, r),
      ],
    );
  }

  Widget _routeCard(TransitProvider provider, dynamic r) {
    // Map points: first stop = start, last stop = end.
    // Fewer than 2 stops (or unknown ids) means no map.
    final first = r.stopIds.length >= 2 ? provider.stopById(r.stopIds.first) : null;
    final last = r.stopIds.length >= 2 ? provider.stopById(r.stopIds.last) : null;
    final hasMap = first != null && last != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RouteCard(
        key: ValueKey(r.id), // keeps expand/collapse state on the right card
        badge: transportBadge(provider.modeName(r.transportModeId)),
        title: r.name,
        via: provider.routeEndpoints(r),
        code: '#${r.routeNo}',
        // regularFare / discountedFare omitted -> card shows TBD (sprint 2)
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
        for (final t in terminals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RouteCard(
              key: ValueKey(t.id),
              badge: provider.modeNamesServing(t.id).map(transportBadge).join(' / '),
              title: t.name,
              // district line left blank: no data behind it yet
              onViewMap: () => _toast('TODO: show terminal on map'),
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
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}