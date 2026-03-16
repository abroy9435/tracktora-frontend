import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/theme.dart';
import 'core/router/router.dart';

void main() async {
  // --- CRITICAL ADDITION ---
  // This ensures Flutter services are ready before loading the .env or running the app
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fallback or debug print if .env is missing
    debugPrint("Warning: .env file not found. Using default configurations.");
  }

  runApp(const TrackTora());
}

class TrackTora extends StatelessWidget {
  const TrackTora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackTora',
      debugShowCheckedModeBanner: false, // Optional: Cleans up the UI
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, 
      routerConfig: router,
    );
  }
}