import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// map imports
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// screens imports
import 'screens/title_screen.dart';

// providers and services imports
import 'providers/transit_provider.dart';
import 'services/transit_service.dart';

// widgets imports
import 'utils/app_theme.dart';

void main() async {
  // Ensures Flutter is initialized before calling asynchronous setup operations.
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim();
  if (mapboxAccessToken == null || mapboxAccessToken.isEmpty) {
    throw StateError(
      'MAPBOX_ACCESS_TOKEN is missing from .env. '
      'Copy .env.example to .env and add your Mapbox public access token.',
    );
  }

  // Initializes Firebase using the platform-specific configuration.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Must be set before any MapWidget is created.
  MapboxOptions.setAccessToken(mapboxAccessToken);

  runApp(
    // Makes TransitProvider available to the entire widget tree.
    ChangeNotifierProvider(
      // Creates the provider with TransitService and immediately loads transit data.
      create: (_) => TransitProvider(TransitService())..load(),
      child: const TaraLargaApp(),
    ),
  );
}

// App entry point
class TaraLargaApp extends StatelessWidget {
  const TaraLargaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tara Larga!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const TitleScreen(),
    );
  }
}