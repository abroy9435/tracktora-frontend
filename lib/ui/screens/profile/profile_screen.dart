import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/cache/auth_cache.dart';
import '../../../core/cache/app_cache.dart';
import '../../../engine/profile_engine.dart';
import '../../../engine/application_engine.dart';
import '../../../engine/auth_engine.dart'; 
import '../../widgets/skeleton.dart';
import '../../../main.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchProfile();
  }

  void _loadCachedData() {
    final cachedUser = AppCache.getProfile();
    if (cachedUser != null) {
      setState(() {
        _user = cachedUser;
        _isLoading = false; 
      });
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ProfileEngine.getProfile();
      if (mounted) {
        // Update Cache with fresh data
        await AppCache.setProfile(response.data); 
        
        setState(() {
          _user = response.data;
          _isLoading = false;
        });
      }
    } on DioException catch (_) {
      if (mounted && _user == null) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthCache.clear();
    await AppCache.clear();
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _showChangePasswordSheet() {
    final formKey = GlobalKey<FormState>();
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('SECURITY UPDATE', 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                const Text('Change Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: currentPwdController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: newPwdController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                  validator: (val) => (val == null || val.length < 6) ? "Must be at least 6 characters" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: confirmPwdController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
                  validator: (val) {
                    if (val != newPwdController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                FilledButton(
                  onPressed: isSaving ? null : () async {
                    if (!formKey.currentState!.validate()) return;

                    setModalState(() => isSaving = true);
                    try {
                      await AuthEngine.updatePassword(currentPwdController.text, newPwdController.text);
                      
                      if (mounted) {
                        Navigator.pop(context); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed: Incorrect current password.'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setModalState(() => isSaving = false);
                    }
                  },
                  child: isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('CONFIRM CHANGES'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;
    final controller = TextEditingController(text: _user!['username']);
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Username'),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: isSaving ? null : () async {
                if (controller.text.trim().isEmpty) return;
                setDialogState(() => isSaving = true);
                try {
                  await ProfileEngine.updateProfile(controller.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    _fetchProfile(); 
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile.')));
                  }
                } finally {
                  if (context.mounted) setDialogState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePrivacy(bool value) async {
    if (_user == null) return;
    setState(() => _user!['share_stats'] = value); 
    try {
      await ProfileEngine.updatePrivacy(value);
    } catch (e) {
      setState(() => _user!['share_stats'] = !value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update privacy settings.')));
      }
    }
  }

  void _showThemeSelector(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildThemeTile(context, 'System Default', Icons.smartphone, ThemeMode.system, 'system', theme),
              _buildThemeTile(context, 'Light Mode', Icons.light_mode, ThemeMode.light, 'light', theme),
              _buildThemeTile(context, 'Dark Mode', Icons.dark_mode, ThemeMode.dark, 'dark', theme),
            ],
          ),
        );
      }
    );
  }

  Widget _buildThemeTile(BuildContext context, String title, IconData icon, ThemeMode mode, String cacheKey, ThemeData theme) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: themeNotifier.value == mode ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: () async {
        themeNotifier.value = mode; // Update UI instantly
        await AppCache.setThemeMode(cacheKey); // Persist to storage
        if (context.mounted) Navigator.pop(context);
        setState(() {}); // Rebuild to show new checkmark
      },
    );
  }

  Future<void> _openWishlist() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return FutureBuilder<Response>(
          future: ApplicationEngine.getList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return const SizedBox(height: 300, child: Center(child: Text('Failed to load wishlist.')));
            }
            final allApps = snapshot.data?.data['applications'] as List<dynamic>? ?? [];
            final wishlist = allApps.where((app) => app['status'] == 'Wishlist').toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Saved Opportunities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    if (wishlist.isEmpty)
                      const Expanded(child: Center(child: Text('No saved jobs found.', style: TextStyle(color: Colors.grey))))
                    else
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: wishlist.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final job = wishlist[index];
                            return ListTile(
                              tileColor: Theme.of(context).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: Text(job['role_title'] ?? 'Role', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(job['company_name'] ?? 'Company'),
                              trailing: Icon(Icons.bookmark, color: Theme.of(context).colorScheme.primary),
                            );
                          },
                        ),
                      ),
                  ],
                );
              }
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: theme.colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _isLoading 
              ? const Skeleton(width: double.infinity, height: 120)
              : GestureDetector(
                  onTap: _showEditProfileDialog,
                  child: Container(
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
                          child: Text(
                            _user?['username']?[0]?.toUpperCase() ?? '?', 
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_user?['username'] ?? 'Unknown User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(_user?['email'] ?? 'No email available', style: TextStyle(color: theme.colorScheme.secondary)),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_outlined, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 32),

            Text('ACTIVITY', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.bookmarks_outlined, color: theme.colorScheme.primary),
              ),
              title: const Text('Saved Opportunities', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Jobs bookmarked from Explore', style: TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _openWishlist,
            ),
            
            const SizedBox(height: 24),

            Text('SETTINGS', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[500], fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              secondary: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.visibility_outlined, color: theme.iconTheme.color),
              ),
              title: const Text('Public Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Let connections see your stats', style: TextStyle(color: Colors.grey, fontSize: 13)),
              value: _user?['share_stats'] ?? false,
              activeColor: theme.colorScheme.primary,
              onChanged: _isLoading ? null : _togglePrivacy,
            ),
            
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.lock_outline, color: theme.iconTheme.color),
              ),
              title: const Text('Security', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Update your access password', style: TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showChangePasswordSheet,
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.dark_mode_outlined, color: theme.iconTheme.color),
              ),
              title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                themeNotifier.value == ThemeMode.system ? 'System Default' : themeNotifier.value == ThemeMode.light ? 'Light Mode' : 'Dark Mode', 
                style: const TextStyle(color: Colors.grey, fontSize: 13)
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _showThemeSelector(context, theme),
            ),

            const SizedBox(height: 40),

            OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('LOG OUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}