import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transit_provider.dart';
import '../utils/transport_labels.dart';
import '../widgets/pill_toggle.dart';
import '../widgets/route_card.dart';
import '../widgets/search_pill.dart';

/// Network tab: routes and terminals, loaded from Firestore via TransitProvider.
class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  // We need to refactor this later to separate constants from the
  // implementation (e.g., put these in a separate constants.dart or
  // declare them in the model as part of the data architecture).
  static const _tabs = ['Routes', 'Terminals'];
  static const _filters = [
    'All Terminals',
    'Jeepney and e-bus Terminals',
    'Bus Terminals',
  ];

  int _tab = 0;
  int _filter = 0;

  // Displays a temporary message at the bottom of the screen.
  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Listens for changes in TransitProvider and rebuilds the screen
    // whenever its transit data or loading state changes.
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

              // Displays the appropriate content based on the selected tab
              // and the current state of the transit data.
              Expanded(child: _buildBody(provider)),
            ],
          ),
        ),
      ),
    );
  }

  // Handles the different states of the transit data before displaying
  // the routes or terminals.
  Widget _buildBody(TransitProvider provider) {
    // Shows a loading indicator while fetching data from Firestore.
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Displays an error message and allows the user to retry loading the data.
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.load,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    // Displays routes or terminals depending on the selected tab.
    return _tab == 0 ? _buildRoutes(provider) : _buildTerminals(provider);
  }

  Widget _buildRoutes(TransitProvider provider) {
    // Retrieves the routes currently available in TransitProvider.
    final routes = provider.routes;

    if (routes.isEmpty) {
      return const Center(child: Text('No routes found'));
    }

    // The data has no city / out-of-town field yet, so all routes are listed
    // under CITY ROUTES for now.
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _sectionTitle('CITY ROUTES'),

        // Generates a RouteCard for each route retrieved from Firestore.
        for (final r in routes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RouteCard(
              // Uses the route ID as its key to help Flutter identify each card.
              key: ValueKey(r.id),
              badge: transportBadge(provider.modeName(r.transportModeId)),
              title: r.name,
              via: provider.routeEndpoints(r),
              code: '#${r.routeNo}',
              onViewMap: () => _toast('TODO: show route on map'),
            ),
          ),
      ],
    );
  }

  Widget _buildTerminals(TransitProvider provider) {
    // Retrieves the terminals currently available in TransitProvider.
    final terminals = provider.terminals;

    if (terminals.isEmpty) {
      return const Center(child: Text('No terminals found'));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        _sectionTitle('MAJOR TERMINALS'),

        // Generates a RouteCard for each terminal retrieved from Firestore.
        for (final t in terminals)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RouteCard(
              // Uses the terminal ID as its key to help Flutter identify each card.
              key: ValueKey(t.id),
              badge: provider
                  .modeNamesServing(t.id)
                  .map(transportBadge)
                  .join(' / '),
              title: t.name,
              onViewMap: () => _toast('TODO: show terminal on map'),
            ),
          ),
      ],
    );
  }

  // Builds a section heading for organizing routes and terminals.
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