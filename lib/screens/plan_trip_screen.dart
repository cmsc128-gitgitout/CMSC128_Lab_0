import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../models/boarding_point.dart';
import '../providers/transit_provider.dart';
import '../widgets/location_field.dart';
import '../widgets/place_tile.dart';
import '../widgets/search_section_label.dart';
import 'choose_on_map_screen.dart';

// Which of the two inputs the user is currently editing.
enum _Field { origin, destination }

// Plan your trip screen: start and destination inputs
// has results container (for either recents / live suggestions) below.
class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key, this.locEnabled = false});

  // Whether live loc is available. Placeholder flag until the location feature exists.
  final bool locEnabled;

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _originFocus = FocusNode();
  final _destFocus = FocusNode();

  // The field the list below belongs to; follows focus
  _Field _active = _Field.destination;

  // Stops the user picked for each field
  // null when field is empty or its text was typed by hand (or is "Your location")
  // TODO: widen to a shared place model so map pins and the user's current location can be stored too.
  BoardingPoint? _origin;
  BoardingPoint? _destination;

  // Text shown in the start field when the user's location is used
  static const _currentLocLabel = 'Your location';

  // Runs once when the screen opens. 
  // Sets up the listeners that keep _active in sync with whichever field has focus.
  @override
  void initState() {
    super.initState();

    // Location on: start is prefilled. 
    // Location off: start stays empty and shows its hint so the user picks a start themselves.
    if (widget.locEnabled) _originCtrl.text = _currentLocLabel;

    _originFocus.addListener(() {
      if (!_originFocus.hasFocus) return;
      setState(() => _active = _Field.origin);

      // Select the "Your location" label so typing replaces it
      if (_originCtrl.text == _currentLocLabel) {
        _originCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _originCtrl.text.length);
      }
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
      final stop = _origin;
      _origin = _destination;
      _destination = stop;
    });
  }

  // Fills the active field with the picked stop and remembers it. 
  // Then focus moves to the other field if it is still empty, so the user can finish the trip.
  void _pick(BoardingPoint stop) {
    // remember it for next time (shared history, max 7, saved on the device)
    context.read<TransitProvider>().addRecentSearch(stop.name);

    setState(() {
      _setText(_activeCtrl, stop.name);
      if (_active == _Field.origin) {
        _origin = stop;
      } else {
        _destination = stop;
      }
    });

    // Both fields filled: the route results step will start here.
    _focusNextEmpty(_active);
  }

  // After filling a field: focus the other one if empty, else close the keyboard.
  void _focusNextEmpty(_Field filled) {
    if (filled == _Field.origin && _destCtrl.text.isEmpty) {
      _destFocus.requestFocus();
    } else if (filled == _Field.destination && _originCtrl.text.isEmpty) {
      _originFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
      _openRouteResults();
    }
  }

  // Single hand-off point to the route results step.
  // TODO: replace with the real route results screen.
  void _openRouteResults() {
    Navigator.of(context).popUntil((route) => route.isFirst); // change it to this Navigator.of(context).push(MaterialPageRoute(builder: (_) => TheirScreen(...))).
  }

  // What the user typed in the active field.
  // The "Your location" label is not a search, so it counts as empty and recents show instead.
  String get _query {
    final text = _activeCtrl.text.trim();
    return text == _currentLocLabel ? '' : text;
  }

  // Second line under a stop's name: terminal flag or the modes serving it.
  String _detailFor(TransitProvider transit, BoardingPoint stop) {
    if (stop.isTerminal) return 'Terminal';
    final modes = transit.modeNamesServing(stop.id);
    return modes.isEmpty ? 'Boarding point' : modes.join(' · ');
  }

  // Recents shown while the active field is empty.
  List<BoardingPoint> _recents(TransitProvider transit) => transit.recentSearches
      .map(transit.stopByName)
      .whereType<BoardingPoint>()
      .toList();

  // True when the stop's name is in the saved history.
  bool _isRecent(TransitProvider transit, BoardingPoint stop) => transit.recentSearches.any(
    (s) => s.toLowerCase() == stop.name.toLowerCase());

  // Live suggestions from provider's stops search. 
  // Matching recents come first so they keep their clock icon.
  List<BoardingPoint> _search(TransitProvider transit, String query) {
    final matches = transit.searchStops(query);
    final recent = matches.where((p) => _isRecent(transit, p));
    final others = matches.where((p) => !_isRecent(transit, p));
    return [...recent, ...others];
  }

  // Opens the map pin picker and fills the field that was active when tapped.
  // TODO: store picked.lat / picked.lng once the shared place model exists.
  Future<void> _chooseOnMap() async {
    // Capture now: focus (and so _active) can change while the map is open.
    final target = _active;
    

    final picked = await Navigator.of(context).push<({double lat, double lng, String name})>(
      MaterialPageRoute(
        builder: (_) => ChooseOnMapScreen(
          pinColor: target == _Field.origin
            ? AppTheme.primary
            : AppTheme.destination,
        )),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _setText(target == _Field.origin ? _originCtrl : _destCtrl, picked.name);
      // a pin is not a BoardingPoint, so clear any stop stored for this field.
      if (target == _Field.origin) {
        _origin = null;
      } else {
        _destination = null;
      }
    });

    _focusNextEmpty(target);
  }

  // Container below the fields:
  // - field empty: recents
  // - user typing: live suggestions (recents are hidden; matching ones are mixed into suggestions)
  Widget _buildResults(TransitProvider transit) {
    // The stop list comes from Firestore, so it can still be loading or have failed.
    // Both states reuse the provider's own flags and retry.
    if (transit.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (transit.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(transit.error!, textAlign: TextAlign.center),
            TextButton(onPressed: transit.load, child: const Text('Try again')),
          ],
        ),
      );
    }

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
          title: const Text('Choose on map', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
          onTap: _chooseOnMap,
        ),
        
        const Divider(height: 1),

        if (stops.isEmpty)
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                isTyping ? 'No places found' : 'Places you search will show up here', 
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
            isRecent: _isRecent(transit, stop),
            onTap: () => _pick(stop)
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
              padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                          onChanged: (_) => setState(() => _origin = null),         // origin field
                        ),
                        const SizedBox(height: 10),
                        LocationField(
                          controller: _destCtrl, 
                          focusNode: _destFocus, 
                          hint: 'Where to?', 
                          icon: Icons.location_on_outlined,
                          iconColor: AppTheme.destination,
                          autofocus: true,            
                          onChanged: (_) => setState(() => _destination = null),    // destination field
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