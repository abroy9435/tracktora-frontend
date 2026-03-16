import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../engine/auth_engine.dart';
import '../../widgets/spinner.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthEngine.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully! Please log in.'), backgroundColor: Colors.green),
          );
          context.go('/login');
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'Registration failed. Please try again.';
      if (e.response != null && e.response?.data['error'] != null) {
        errorMessage = e.response?.data['error']; 
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset('assets/logo.svg', height: 80),
                const SizedBox(height: 24),
                // Removed hardcoded Colors.white
                Text('Join the Hunt', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Create your TrackTora profile.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 40),

                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  // Let the theme handle the text color
                  decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                FilledButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CyberSpinner(color: Colors.white, size: 24, strokeWidth: 2)
                      : const Text('ESTABLISH PROFILE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => context.pop(), 
                      child: Text('Sign In', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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