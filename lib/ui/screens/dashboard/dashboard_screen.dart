import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../engine/application_engine.dart';
import '../../widgets/skeleton.dart';
import '../../../core/cache/app_cache.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, dynamic> _stats = {};
  List<dynamic> _applications = [];

  final List<String> _statusOptions = ['Wishlist', 'Applied', 'Interviewing', 'Offer', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadCachedDashboard();
    _fetchDashboardData();
  }

  void _loadCachedDashboard() {
    final cachedStats = AppCache.getStats();
    final cachedApps = AppCache.getApplications(); // Use the new list cache
    
    if (cachedStats != null || cachedApps != null) {
      setState(() {
        if (cachedStats != null) _stats = cachedStats;
        if (cachedApps != null) _applications = cachedApps;
        _isLoading = false; 
      });
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final results = await Future.wait([
        ApplicationEngine.getStats(),
        ApplicationEngine.getList(),
      ]);

      final freshStats = results[0].data;
      final freshApps = results[1].data['applications'] ?? [];

      // Update Persistence
      await AppCache.setStats(freshStats);
      await AppCache.setApplications(freshApps);

      if (mounted) {
        setState(() {
          _stats = freshStats;
          _applications = freshApps;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } on DioException catch (_) { 
      if (mounted && _applications.isEmpty) {
        setState(() {
          _errorMessage = 'Unable to load data.\nPlease check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  // --- REPOSITORY LOGIC ---

  void _handleDeleteApplication(int index, Map<String, dynamic> app) {
    final appId = app['id'].toString(); 
    final appName = app['company_name'] ?? 'Opportunity';

    setState(() => _applications.removeAt(index));

    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$appName removed from tracker'),
        duration: const Duration(seconds: 4), 
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            if (mounted) setState(() => _applications.insert(index, app));
          },
        ),
      ),
    ).closed.then((reason) async {
      if (reason != SnackBarClosedReason.action) {
        try {
          await ApplicationEngine.deleteApplication(appId);
          _refreshStatsOnly(); 
        } catch (e) {
          if (mounted) {
            setState(() => _applications.insert(index, app));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Network error. Failed to delete.')),
            );
          }
        }
      }
    });
  }

  Future<void> _refreshStatsOnly() async {
    try {
      final response = await ApplicationEngine.getStats();
      if (mounted) {
        setState(() => _stats = response.data);
        await AppCache.setStats(response.data);
      }
    } catch (_) {}
  }

  // --- UI COMPONENTS ---

  void _showJobDetailsSheet(BuildContext context, Map<String, dynamic> app, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2), 
                        child: Text(app['company_name']?[0]?.toUpperCase() ?? '?', style: TextStyle(fontSize: 24, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app['role_title'] ?? 'Unknown Role', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(app['company_name'] ?? 'Unknown Company', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(Icons.timeline, 'Status', app['status'] ?? 'Applied', theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_month, 'Applied On', app['applied_date'] ?? 'Not specified', Colors.grey[300]!),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.link, 'Job URL', app['job_url'] != null && app['job_url'].toString().isNotEmpty ? app['job_url'] : 'No URL provided', Colors.blueAccent),
                  
                  const SizedBox(height: 24),
                  Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      app['notes'] != null && app['notes'].toString().isNotEmpty ? app['notes'] : 'No notes added for this opportunity.',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); 
                        _showUpdateStatusSheet(context, app, theme); 
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('UPDATE STATUS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateStatusSheet(BuildContext context, Map<String, dynamic> app, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Update Status', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${app['role_title']} at ${app['company_name']}', style: TextStyle(color: Colors.grey[500])),
              const SizedBox(height: 16),
              ..._statusOptions.map((status) {
                final isCurrent = app['status'] == status;
                return ListTile(
                  title: Text(status, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  trailing: isCurrent ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
                  onTap: () async {
                    Navigator.pop(context); 
                    if (isCurrent) return;
                    
                    try {
                      final payload = {
                        'id': app['id'].toString(),
                        'company_name': app['company_name'] ?? '',
                        'role_title': app['role_title'] ?? '',
                        'status': status, 
                        'job_url': app['job_url'] ?? '',
                        'notes': app['notes'] ?? '',
                        'applied_date': app['applied_date'] ?? '',
                      };
                      await ApplicationEngine.updateApplication(payload);
                      _fetchDashboardData(); 
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moved to $status!')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status.', style: TextStyle(color: theme.colorScheme.error))));
                    }
                  },
                );
              }),
            ],
          ),
        );
      }
    );
  }

  void _showAddApplicationSheet(BuildContext context, ThemeData theme) {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final urlController = TextEditingController();
    final notesController = TextEditingController();
    
    String selectedStatus = 'Applied';
    DateTime selectedDate = DateTime.now();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                left: 24, right: 24, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add New Opportunity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(controller: companyController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Company Name *', prefixIcon: Icon(Icons.business))),
                    const SizedBox(height: 16),
                    TextField(controller: roleController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Role Title *', prefixIcon: Icon(Icons.work_outline))),
                    const SizedBox(height: 16),
                    TextField(controller: urlController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Job URL (Optional)', prefixIcon: Icon(Icons.link))),
                    const SizedBox(height: 16),
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: selectedStatus,
                            decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.timeline)),
                            dropdownColor: theme.colorScheme.surface,
                            items: _statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (value) { if (value != null) setModalState(() => selectedStatus = value); },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
                              if (date != null) setModalState(() => selectedDate = date);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Applied Date', prefixIcon: Icon(Icons.calendar_month)),
                              child: Text(selectedDate.toIso8601String().split('T')[0]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes (Optional)', prefixIcon: Icon(Icons.notes))),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: isSubmitting ? null : () async {
                        if (companyController.text.isEmpty || roleController.text.isEmpty) return;
                        setModalState(() => isSubmitting = true);
                        try {
                          final payload = {
                            'company_name': companyController.text.trim(),
                            'role_title': roleController.text.trim(),
                            'status': selectedStatus,
                            'job_url': urlController.text.trim(),
                            'notes': notesController.text.trim(),
                            'applied_date': selectedDate.toIso8601String().split('T')[0],
                          };
                          await ApplicationEngine.addApplication(payload);
                          if (context.mounted) { Navigator.pop(context); setState(() => _isLoading = true); _fetchDashboardData(); }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add job.', style: TextStyle(color: theme.colorScheme.error))));
                        } finally {
                          if (context.mounted) setModalState(() => isSubmitting = false);
                        }
                      },
                      child: isSubmitting 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SAVE TO TRACKER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
        title: const Text('STATUS OVERVIEW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() { _isLoading = true; _errorMessage = null; }); _fetchDashboardData(); })
        ],
      ),
      body: _isLoading 
        ? _buildSkeletonDashboard(theme) 
        : _errorMessage != null 
          ? _buildErrorState(theme) 
          : _buildDashboardContent(theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddApplicationSheet(context, theme),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('TRACK JOB', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSkeletonDashboard(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonStatCard(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonStatCard(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonStatCard(theme)),
          ],
        ),
        const SizedBox(height: 32),
        Text('RECENT ACTIVITY', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        ...List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tileColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Skeleton(width: 40, height: 40, borderRadius: 20),
            title: const Skeleton(width: 120, height: 16),
            subtitle: const Padding(padding: EdgeInsets.only(top: 8.0), child: Skeleton(width: 80, height: 12)),
            trailing: const Skeleton(width: 60, height: 24, borderRadius: 12),
          ),
        )),
      ],
    );
  }

  Widget _buildSkeletonStatCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: const Column( 
        children: [
          Skeleton(width: 40, height: 32),
          SizedBox(height: 8),
          Skeleton(width: 60, height: 12),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      color: theme.colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('Active', _stats['total']?.toString() ?? '0', theme.colorScheme.primary)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Interviews', _stats['interviewing']?.toString() ?? '0', Colors.orangeAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Offers', _stats['offer']?.toString() ?? '0', Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 32),
          Text('RECENT ACTIVITY', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _applications.isEmpty 
            ? Padding(padding: const EdgeInsets.all(32.0), child: Center(child: Text('No active tracking data found.\nStart your search.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500]))))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _applications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = _applications[index];
                  return Dismissible(
                    key: Key(app['id']?.toString() ?? index.toString()),
                    direction: DismissDirection.endToStart, 
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    onDismissed: (direction) => _handleDeleteApplication(index, app),
                    child: _buildApplicationTile(app, theme),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1), 
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildApplicationTile(Map<String, dynamic> app, ThemeData theme) {
    Color statusColor = theme.colorScheme.secondary;
    if (app['status'] == 'Interviewing') statusColor = Colors.orangeAccent;
    if (app['status'] == 'Offer') statusColor = Colors.greenAccent;
    if (app['status'] == 'Rejected') statusColor = Colors.redAccent;
    if (app['status'] == 'Wishlist') statusColor = Colors.grey;

    return ListTile(
      onTap: () => _showJobDetailsSheet(context, app, theme), 
      onLongPress: () => _showUpdateStatusSheet(context, app, theme),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.2), 
        child: Text(app['company_name']?[0]?.toUpperCase() ?? '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(app['role_title'] ?? 'Unknown Role', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(app['company_name'] ?? 'Unknown Company', style: TextStyle(color: Colors.grey[500])),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: Text(app['status'] ?? 'Applied', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}