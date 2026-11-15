import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../models/boarding_point.dart';
import '../providers/transit_provider.dart';
import '../widgets/location_field.dart';
import '../widgets/place_tile.dart';
import '../widgets/search_section_label.dart';
import 'choose_on_map_screen.dart';

// Placeholder recents (boarding point ids) until previous searches are stored. 
// TODO: replace with real search history.
const _placeholderRecentIds = ['S26', 'S38']; // Robinsons Jaro, SM City

// Which of the two inputs the user is currently editing.
enum _Field { origin, destination }

// Plan your trip screen: start and destination inputs
// has results container (for either recents / live suggestions) below.
class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _originFocus = FocusNode();
  final _destFocus = FocusNode();

  // The field the list below belongs to. Follows focus.
  _Field _active = _Field.destination;

  // Runs once when the screen opens. 
  // Sets up the listeners that keep _active in sync with whichever field has focus.
  @override
  void initState() {
    super.initState();

    _originFocus.addListener(() {
      if (_originFocus.hasFocus) setState(() => _active = _Field.origin);
    });

    _destFocus.addListener(() {
      if (_destFocus.hasFocus) setState(() => _active = _Field.destination);
    });
  }

  // Runs when the screen closes.
  // Controllers and focus nodes must be disposed manually, or they leak memory.
  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  // Controller of the field the user is currently editing.
  TextEditingController get _activeCtrl =>
      _active == _Field.origin ? _originCtrl : _destCtrl;

  // Sets a field's text and keeps the cursor at the end (Assigning controller.text directly can reset the cursor position)
  void _setText(TextEditingController ctrl, String text) {
    ctrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  // Swaps the two inputs.
  void _swap() {
    final origin = _originCtrl.text;
    setState(() {
      _setText(_originCtrl, _destCtrl.text);
      _setText(_destCtrl, origin);
    });
  }

  // What the user typed in the active field.
  String get _query => _activeCtrl.text.trim();

  // Second line under a stop's name: terminal flag or the modes serving it.
  String _detailFor(TransitProvider transit, BoardingPoint stop) {
    if (stop.isTerminal) return 'Terminal';
    final modes = transit.modeNamesServing(stop.id);
    return modes.isEmpty ? 'Boarding point' : modes.join(' · ');
  }

  // Recents shown while the active field is empty.
  List<BoardingPoint> _recents(TransitProvider transit) => _placeholderRecentIds
      .map(transit.stopById)
      .whereType<BoardingPoint>()
      .toList();

  // Live suggestions: stops whose name contains the typed text. 
  // Matching recents come first so they keep their clock icon.
  // Local filtering for now; this is the place to swap in a real places search later.

  List<BoardingPoint> _search(TransitProvider transit, String query) {
    final q = query.toLowerCase();
    final matches =
        transit.boardingPoints.where((p) => p.name.toLowerCase().contains(q));
    final recent = matches.where((p) => _placeholderRecentIds.contains(p.id));
    final others = matches.where((p) => !_placeholderRecentIds.contains(p.id));
    return [...recent, ...others];
  }

  // Opens the map pin picker. 
  // The skeleton screen does not return a location yet. 
  // TODO: Handle its result here once it does (a pin is not a BoardingPoint, so that needs the wider shared place model).
  void _chooseOnMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChooseOnMapScreen()),
    );
  }

  // Container below the fields:
  // - field empty: recents
  // - user typing: live suggestions (recents are hidden; matching ones are mixed into suggestions)
  Widget _buildResults(TransitProvider transit) {
    final isTyping = _query.isNotEmpty;
    final stops = isTyping ? _search(transit, _query) : _recents(transit);

    return ListView(
      padding: EdgeInsets.zero,
      // Hide the keyboard when the user scrolls the list.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        // Always available, in every state.
        ListTile(
          leading: const Icon(Icons.map_outlined, color: AppTheme.primary),
          title: const Text('Choose on map'),
          onTap: _chooseOnMap,
        ),
        
        const Divider(height: 1),

        if (isTyping && stops.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No places found', 
                style: TextStyle(color: Color(0xFF5F6368))
              ),
            ),
          )
        else ...[
          SectionLabel(isTyping ? 'SUGGESTIONS' : 'RECENT'),
          for (final stop in stops)
          PlaceTile(
            name: stop.name,
            detail: _detailFor(transit, stop),
            isRecent: _placeholderRecentIds.contains(stop.id),
            onTap: () {}, // wired in a later commit
          ),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transit = context.watch<TransitProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back button + title
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Text(
                    'Plan your trip',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            
            // Start + destination fields and the swap button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        LocationField(
                          controller: _originCtrl, 
                          focusNode: _originFocus, 
                          hint: 'Start location', 
                          icon: Icons.circle, 
                          iconSize: 12,
                          iconColor: AppTheme.primary,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        LocationField(
                          controller: _destCtrl, 
                          focusNode: _destFocus, 
                          hint: 'Where to?', 
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFFD32F2F),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: _swap, 
                    tooltip: 'Swap start and destination',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: AppTheme.primary,
                    ),
                    icon: const Icon(Icons.swap_vert),
                  ),
                ],
              ),
            ),

            // The results container (recents / suggestions) goes here.
            Expanded(child: _buildResults(transit)),
          ],
        ),
      ),
    );
  }
}