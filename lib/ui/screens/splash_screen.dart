import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/cache/auth_cache.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a slight delay so the user actually sees your branding for a moment
    await Future.delayed(const Duration(seconds: 2));

    // Read the token securely
    final token = await AuthCache.getToken();

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Token exists! Send them straight to the Dashboard
        context.go('/home');
      } else {
        // No token found. Send them to Login
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Assuming you want to show your logo here while it checks
        child: SvgPicture.asset('assets/logo.svg', height: 120),
      ),
    );
  }
}