import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../engine/connect_engine.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _friends = [];
  bool _isSearching = false;
  bool _isLoadingFriends = true;
  
  String? _processingUserId; 
  final Set<String> _sentRequests = {}; 
  
  Timer? _debounce;
  String _currentSearchToken = '';

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await ConnectEngine.getFriendList();
      if (mounted) {
        setState(() {
          _friends = response.data['friends'] ?? [];
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFriends = false);
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState((){}); // Refresh UI for clear button
    
    final query = val.trim();
    if (query.length < 3) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    final searchToken = DateTime.now().millisecondsSinceEpoch.toString();
    _currentSearchToken = searchToken;

    try {
      final response = await ConnectEngine.searchUsers(query);
      if (mounted && _currentSearchToken == searchToken) {
        setState(() {
          _searchResults = response.data['results'] ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted && _currentSearchToken == searchToken) {
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _handleInviteAction(String friendId, String name, bool isSending) async {
    setState(() => _processingUserId = friendId);
    try {
      if (isSending) {
        await ConnectEngine.sendInvite(friendId);
        if (mounted) {
          setState(() {
            _sentRequests.add(friendId);
            _processingUserId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to $name!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        }
      } else {
        await ConnectEngine.cancelInvite(friendId);
        if (mounted) {
          setState(() {
            _sentRequests.remove(friendId);
            _processingUserId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request cancelled.'), behavior: SnackBarBehavior.floating));
        }
      }
    } catch (e) {
      if (mounted) setState(() => _processingUserId = null);
    }
  }

  void _showFriendStatsSheet(BuildContext context, dynamic friend) {
    final theme = Theme.of(context);
    final name = (friend['username'] ?? 'User').toString();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return FutureBuilder<Response>(
          future: ConnectEngine.getFriendStats((friend['friend_id'] ?? friend['id'] ?? '').toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SizedBox(height: 250, child: Center(child: Text('User stats are private or unavailable')));
            }
            final stats = snapshot.data?.data ?? {};
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$name's Stats", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Active', (stats['total'] ?? '0').toString(), theme.colorScheme.primary),
                      _statItem('Interviews', (stats['interviewing'] ?? '0').toString(), Colors.orangeAccent),
                      _statItem('Offers', (stats['offer'] ?? '0').toString(), Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('CONNECTIONS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _onSearchChanged(''); }) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 20),
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_searchController.text.length >= 3 && _searchResults.isEmpty)
              const Center(child: Text("No users found", style: TextStyle(color: Colors.grey)))
            else if (_searchResults.isNotEmpty) ...[
              const Text('SEARCH RESULTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, i) {
                    final user = _searchResults[i];
                    final String userId = (user['id'] ?? '').toString();
                    final String name = (user['username'] ?? 'User').toString();
                    final isProcessing = _processingUserId == userId;
                    final hasSent = _sentRequests.contains(userId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text((user['email'] ?? '').toString()),
                        // FIX: Wrapped in SizedBox to prevent layout crash
                        trailing: SizedBox(
                          width: 100, 
                          child: isProcessing
                            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                            : hasSent 
                              ? OutlinedButton(
                                  onPressed: () => _handleInviteAction(userId, name, false), 
                                  child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                                )
                              : FilledButton(
                                  onPressed: () => _handleInviteAction(userId, name, true), 
                                  child: const Text('Connect', style: TextStyle(fontSize: 11)),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ] else ...[
              const Text('MY CONNECTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              if (_isLoadingFriends) const Center(child: CircularProgressIndicator())
              else if (_friends.isEmpty) const Center(child: Text("No connections yet", style: TextStyle(color: Colors.grey)))
              else Expanded(
                child: ListView.builder(
                  itemCount: _friends.length,
                  itemBuilder: (context, i) {
                    final friend = _friends[i];
                    final name = (friend['username'] ?? 'Friend').toString();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.bar_chart, color: Colors.greenAccent),
                        onTap: () => _showFriendStatsSheet(context, friend),
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}