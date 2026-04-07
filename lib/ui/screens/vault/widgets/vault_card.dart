import 'package:flutter/material.dart';
import '../../../../engine/resume_engine.dart';

class VaultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String id;

  const VaultCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildMoreMenu(context),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 20),
      padding: EdgeInsets.zero,
      onSelected: (value) async {
        if (value == 'delete') {
          final confirm = await _showDeleteDialog(context);
          if (confirm == true) {
            await ResumeEngine.deleteVaultItem(category, id);
            // In a real app, you'd use a state management solution here,
            // but for now, we'll rely on the manual refresh we built into the Screen.
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text("Edit"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, size: 20, color: Colors.red[400]),
            title: Text("Delete", style: TextStyle(color: Colors.red[400])),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("This will remove this item from your Master Vault permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}