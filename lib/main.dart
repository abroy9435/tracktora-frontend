import 'package:flutter/material.dart';
import 'core/config/theme.dart';
import 'core/router/router.dart';

void main() {
  runApp(const TrackTora());
}

class TrackTora extends StatelessWidget {
  const TrackTora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackTora',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Auto-switches based on phone settings
      routerConfig: router,
    );
  }
}