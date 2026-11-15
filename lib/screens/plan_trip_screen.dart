import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/location_field.dart';

// import 'choose_on_map_screen.dart';

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

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _originFocus.dispose();
    _destFocus.dispose();
    super.dispose();
  }

  TextEditingController get _activeCtrl =>
      _active == _Field.origin ? _originCtrl : _destCtrl;

  // Sets a field's text and keeps the cursor at the end.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan your trip')),
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
                        ),
                        const SizedBox(height: 10),
                        LocationField(
                          controller: _destCtrl, 
                          focusNode: _destFocus, 
                          hint: 'Where to?', 
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFFD32F2F),
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Start location input
//           TextField(decoration: InputDecoration(hintText: 'Start location')),
//           SizedBox(height: 12),

//           // Destination input
//           TextField(decoration: InputDecoration(hintText: 'Where to?')),
//           SizedBox(height: 12),

//           // Opens the map pin picker (wired up in a later commit)
//           ListTile(
//             leading: Icon(Icons.map_outlined),
//             title: Text('Choose on map'),
//             onTap: () => Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const ChooseOnMapScreen()),
//             ),
//           ),

//           // List sections (placeholders)
//           Text('SUGGESTIONS'),
//           Text('RECENT'),
//         ],
//       ),
//     );
//   }
// }