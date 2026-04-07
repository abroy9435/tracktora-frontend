import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../engine/resume_engine.dart';
import '../../../widgets/spinner.dart';

class AddCertificationSheet extends StatefulWidget {
  const AddCertificationSheet({super.key});

  @override
  State<AddCertificationSheet> createState() => _AddCertificationSheetState();
}

class _AddCertificationSheetState extends State<AddCertificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _urlController = TextEditingController();
  DateTime? _issueDate;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ResumeEngine.addToVault('certification', {
        'name': _nameController.text.trim(),
        'issuing_organization': _orgController.text.trim(),
        'issue_date': _issueDate?.toIso8601String(),
        'credential_url': _urlController.text.trim(),
      });
      if (mounted && response.statusCode == 201) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("NEW CERTIFICATION", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Certificate Name*", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orgController,
              decoration: const InputDecoration(labelText: "Issuing Org*", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_issueDate == null ? "Select Issue Date" : DateFormat('MMMM yyyy').format(_issueDate!)),
              trailing: const Icon(Icons.event_note_outlined),
              onTap: () async {
                final d = await showDatePicker(
                  context: context, 
                  initialDate: DateTime.now(), 
                  firstDate: DateTime(2010), 
                  lastDate: DateTime.now()
                );
                if (d != null) setState(() => _issueDate = d);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: "Credential URL", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading 
                ? const CyberSpinner(color: Colors.white, size: 24, strokeWidth: 2) 
                : const Text("SAVE TO VAULT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}