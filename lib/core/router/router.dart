import 'package:go_router/go_router.dart';
import '../../ui/layouts/main_layout.dart'; 
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/auth/forgot_password_screen.dart';
import '../../ui/screens/auth/verify_email_screen.dart';
import '../../ui/screens/auth/reset_password_screen.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/connect/pending_requests_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    
    // Auto-Login Update: Extract the Map containing email and password
    GoRoute(
      path: '/verify-email', 
      builder: (context, state) {
        final args = state.extra as Map<String, String>;
        return VerifyEmailScreen(
          email: args['email'] ?? '',
          password: args['password'] ?? '', // Passes the password securely in memory
        );
      }
    ),
    
    GoRoute(
      path: '/reset-password', 
      builder: (context, state) => ResetPasswordScreen(email: state.extra as String),
    ),
    GoRoute(
      path: '/pending-requests', 
      builder: (context, state) => const PendingRequestsScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const MainLayout()),
  ],
);