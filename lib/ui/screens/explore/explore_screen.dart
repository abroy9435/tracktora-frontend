import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../engine/explore_engine.dart';
import '../../widgets/skeleton.dart'; 
import '../../widgets/spinner.dart'; 

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _opportunities = [];
  
  int? _savingIndex; 

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    try {
      final response = await ExploreEngine.getFeed();
      if (mounted) {
        setState(() {
          _opportunities = response.data['explore_feed'] ?? []; 
          _isLoading = false;
        });
      }
    } on DioException catch (_) { 
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load the feed.\nPlease try again later.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveOpportunity(String company, String role, String url, int index) async {
    setState(() => _savingIndex = index);
    try {
      await ExploreEngine.saveOpportunity(company, role, url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opportunity added to your tracker!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingIndex = null);
    }
  }

  // --- NEW: Opportunity Details Sheet (Matches Dashboard Style) ---
  void _showOpportunityDetailsSheet(BuildContext context, Map<String, dynamic> opp, ThemeData theme, int index) {
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
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2), 
                        child: Text(opp['company']?[0]?.toUpperCase() ?? '?', style: TextStyle(fontSize: 24, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opp['title'] ?? 'Unknown Role', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(opp['company'] ?? 'Unknown Company', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(Icons.location_on, 'Location', opp['location'] ?? 'Not specified', theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.link, 'Source URL', opp['apply_url'] != null && opp['apply_url'].toString().isNotEmpty ? opp['apply_url'] : 'Direct Search', Colors.blueAccent),
                  
                  const SizedBox(height: 24),
                  Text('Job Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      opp['description'] ?? 'No additional description provided.',
                      style: TextStyle(color: Colors.grey[300], height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _savingIndex != null ? null : () {
                        Navigator.pop(context);
                        _saveOpportunity(
                          opp['company'] ?? 'Unknown',
                          opp['title'] ?? 'Unknown',
                          opp['apply_url'] ?? '',
                          index,
                        );
                      },
                      icon: _savingIndex == index 
                        ? const CyberSpinner(size: 16, strokeWidth: 2) 
                        : const Icon(Icons.bookmark_add),
                      label: Text(_savingIndex == index ? 'TRACKING...' : 'START TRACKING THIS JOB'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
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
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPLORE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() { _isLoading = true; _errorMessage = null; });
              _fetchFeed();
            },
          )
        ],
      ),
      body: _isLoading 
        ? _buildSkeletonFeed()
        : _errorMessage != null
          ? _buildErrorState(theme)
          : _buildFeedList(theme),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonFeed() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Skeleton(width: 50, height: 50, borderRadius: 25),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 150, height: 16),
                        SizedBox(height: 8),
                        Skeleton(width: 100, height: 12),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Skeleton(width: double.infinity, height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedList(ThemeData theme) {
    if (_opportunities.isEmpty) {
      return const Center(child: Text('No new opportunities found.', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _fetchFeed,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _opportunities.length,
        itemBuilder: (context, index) {
          final opp = _opportunities[index];
          final isSavingThis = _savingIndex == index;
          
          return GestureDetector(
            onTap: () => _showOpportunityDetailsSheet(context, opp, theme, index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2), 
                        child: Text(
                          opp['company']?[0]?.toUpperCase() ?? '?', 
                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opp['title'] ?? 'Unknown Role',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              opp['company'] ?? 'Unknown Company',
                              style: TextStyle(color: theme.colorScheme.secondary),
                            ),
                          ],
                        ),
                      ),
                      if (opp['location'] != null)
                        Text(opp['location'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    opp['description'] ?? 'No description provided.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isSavingThis ? null : () {
                        _saveOpportunity(
                          opp['company'] ?? 'Unknown',
                          opp['title'] ?? 'Unknown',
                          opp['apply_url'] ?? '',
                          index,
                        );
                      },
                      icon: isSavingThis 
                        ? const CyberSpinner(size: 16, strokeWidth: 2) 
                        : Icon(Icons.bookmark_add_outlined, color: theme.colorScheme.primary),
                      label: Text(
                        isSavingThis ? 'TRACKING...' : 'TRACK THIS OPPORTUNITY', 
                        style: TextStyle(color: theme.colorScheme.primary)
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}