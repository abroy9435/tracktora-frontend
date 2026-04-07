import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:pinput/pinput.dart';
import '../../../engine/auth_engine.dart';
import '../../widgets/spinner.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String password; // Added for silent auto-login

  const VerifyEmailScreen({
    super.key, 
    required this.email, 
    required this.password,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _handleVerify([String? autoCode]) async {
    // If autoCode is provided by Pinput, use it. Otherwise, use the controller text.
    final code = autoCode ?? _pinController.text;

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await AuthEngine.verifyEmail(widget.email, code);
      
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Verified! Logging you in...'), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // --- SILENT AUTO-LOGIN ---
        try {
          final loginResponse = await AuthEngine.login(widget.email, widget.password);
          if (loginResponse.statusCode == 200 && mounted) {
            context.go('/home'); // Route directly to Dashboard
          }
        } catch (loginError) {
          // Fallback if silent login somehow fails
          if (mounted) context.go('/login');
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['error'] ?? 'Verification failed.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _pinController.clear();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    try {
      await AuthEngine.resendVerification(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent to your email!'), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.response?.data['error'] ?? 'Failed to resend.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures button spans full width
              children: [
                Icon(Icons.mark_email_read_outlined, size: 80, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text('Verify Your Email', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),
                
                // The beautiful 6-box input
                Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: theme.colorScheme.primary, width: 2),
                    ),
                  ),
                  // Triggers _handleVerify the moment the 6th digit is typed
                  onCompleted: (pin) => _handleVerify(pin),
                ),
                
                const SizedBox(height: 40),
                
                // Submit Button that displays the loader
                FilledButton(
                  onPressed: _isLoading ? null : () => _handleVerify(),
                  child: _isLoading
                      ? const CyberSpinner(color: Colors.white, size: 24, strokeWidth: 2)
                      : const Text('VERIFY & ENTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ", style: TextStyle(color: Colors.grey[400])),
                    _isResending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : TextButton(
                            onPressed: _handleResend,
                            child: Text('Resend', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}