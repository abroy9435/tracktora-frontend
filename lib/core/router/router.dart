import 'package:go_router/go_router.dart';
import '../../ui/layouts/main_layout.dart'; // Import the layout
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/auth/forgot_password_screen.dart';
import '../../ui/screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

    GoRoute(path: '/home', builder: (context, state) => const MainLayout()),
  ],
);