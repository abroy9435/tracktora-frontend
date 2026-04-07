import 'package:flutter/material.dart';
import '../../../../engine/resume_engine.dart';
import '../../../widgets/spinner.dart';

class AddProjectSheet extends StatefulWidget {
  const AddProjectSheet({super.key});

  @override
  State<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<AddProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stackController = TextEditingController();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ResumeEngine.addToVault('project', {
        'project_name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'tech_stack': _stackController.text.trim(),
        'project_url': _urlController.text.trim(),
      });

      if (mounted && response.statusCode == 201) {
        Navigator.pop(context, true); // Returns true to trigger refresh in VaultScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save project: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stackController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("ADD PROJECT", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Project Name*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Enter project name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Enter a brief description" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stackController,
                decoration: const InputDecoration(labelText: "Tech Stack (e.g. Flutter, Go)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: "Project URL (GitHub/Live)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const CyberSpinner(color: Colors.white, size: 24, strokeWidth: 2) 
                  : const Text("SAVE TO VAULT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}