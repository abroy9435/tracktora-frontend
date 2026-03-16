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
          _opportunities = response.data['explore_feed'] ?? []; // Targeting correct key from Go backend
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPPORTUNITIES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.primary)))
          : _buildFeedList(theme),
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
          
          return Container(
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
                        opp['company']?[0] ?? '?', 
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opp['role'] ?? 'Unknown Role',
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
                      Text(opp['location'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  opp['description'] ?? 'No description provided.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isSavingThis ? null : () {
                      _saveOpportunity(
                        opp['company'] ?? 'Unknown',
                        opp['role'] ?? 'Unknown',
                        opp['url'] ?? '',
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
          );
        },
      ),
    );
  }
}