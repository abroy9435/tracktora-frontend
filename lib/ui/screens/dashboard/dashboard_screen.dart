import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../engine/application_engine.dart';
import '../../widgets/skeleton.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  Map<String, dynamic> _stats = {'total': 0, 'interviews': 0, 'offers': 0};
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final results = await Future.wait([
        ApplicationEngine.getStats(),
        ApplicationEngine.getList(),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0].data; 
          _applications = results[1].data['applications'] ?? []; // Ensure it targets the 'applications' array
          _isLoading = false;
        });
      }
    } on DioException catch (_) { 
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load data.\nPlease check your connection.';
          _isLoading = false;
        });
      }
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() { _isLoading = true; _errorMessage = null; });
              _fetchDashboardData();
            },
          )
        ],
      ),
      body: _isLoading 
        ? _buildSkeletonDashboard(theme)
        : _errorMessage != null
          ? _buildErrorState(theme)
          : _buildDashboardContent(theme),
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
        
        Text(
          'RECENT ACTIVITY',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        ...List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tileColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Skeleton(width: 40, height: 40, borderRadius: 20),
            title: const Skeleton(width: 120, height: 16),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Skeleton(width: 80, height: 12),
            ),
            trailing: const Skeleton(width: 60, height: 24, borderRadius: 12),
          ),
        )),
      ],
    );
  }

  Widget _buildSkeletonStatCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
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
              Expanded(child: _buildStatCard('Active', _stats['total'].toString(), theme.colorScheme.primary)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Interviews', _stats['interviews'].toString(), Colors.orangeAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Offers', _stats['offers'].toString(), Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'RECENT ACTIVITY',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _applications.isEmpty 
            ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No active tracking data found.\nStart your search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _applications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = _applications[index];
                  return _buildApplicationTile(app, theme);
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
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1), 
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildApplicationTile(Map<String, dynamic> app, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2), 
        child: Text(app['company_name']?[0] ?? '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
      ),
      title: Text(app['role_title'] ?? 'Unknown Role', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(app['company_name'] ?? 'Unknown Company', style: TextStyle(color: Colors.grey[600])),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2), 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          app['status'] ?? 'Applied',
          style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}