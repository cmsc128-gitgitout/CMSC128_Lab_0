import 'package:flutter/material.dart';

// firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// screens imports
import 'screens/home_screen.dart';

// widgets imports
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TaraLargaApp());
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
      home: const HomeScreen(),
    );
  }
}
