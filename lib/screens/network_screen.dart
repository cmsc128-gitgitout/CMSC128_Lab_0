import 'package:flutter/material.dart';

import '../widgets/pill_toggle.dart';
import '../widgets/route_card.dart';
import '../widgets/search_pill.dart';
import '../widgets/route_card.dart';

/// Network tab: routes and terminals (UI only, no data yet).
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
  int _filter = 0;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: _tab == 0 ? _buildRoutes() : _buildTerminals(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutes() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      // irefactor ni kay as of now, bad practice pa ni
      // kay naggamit kita di counters and gingamit lang siya 
      // para maindicate ang number kang widget nga idisplay
      // TODO: if naimplement na ang backend let's use ang data 
      // for state changes and irender lang kang ui if may any changes
      children: [
        ..._section('CITY ROUTES', count: 2),
        ..._section('OUT OF TOWN ROUTES', count: 2),
      ],
    );
  }

  Widget _buildTerminals() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      // same with this one gingamit lang ni for widget display
      // ichange ta ni if may ara na data
      children: [
        _sectionTitle('MAJOR TERMINALS'),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RouteCard(
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

  List<Widget> _section(String title, {required int count}) {
    return [
      _sectionTitle(title),
      for (int i = 0; i < count; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RouteCard(
            onViewMap: () => _toast('TODO: show route on map'),
          ),
        ),
    ];
  }
}