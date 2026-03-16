import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cache/auth_cache.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await AuthCache.clear();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPERATIVE DATA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)), 
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2), 
                  child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Operative', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Hunter',
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'SYSTEM PREFERENCES',
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notification Uplink',
            subtitle: 'Manage alert frequency',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security & Protocol',
            subtitle: 'Change password or data settings',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Interface Theme',
            subtitle: 'Currently matching system settings',
          ),

          const SizedBox(height: 40),

          OutlinedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            label: const Text(
              'DISCONNECT',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}