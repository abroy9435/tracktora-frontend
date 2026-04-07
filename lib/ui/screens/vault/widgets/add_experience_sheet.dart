import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../engine/resume_engine.dart';
import '../../../widgets/spinner.dart';

class AddExperienceSheet extends StatefulWidget {
  const AddExperienceSheet({super.key});

  @override
  State<AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<AddExperienceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _bulletsController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate() || _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Start date is required")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ResumeEngine.addToVault('experience', {
        'company_name': _companyController.text.trim(),
        'role_title': _roleController.text.trim(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _isCurrent ? null : _endDate?.toIso8601String(),
        'is_current': _isCurrent,
        'bullet_points': _bulletsController.text.trim(),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("WORK EXPERIENCE", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: "Company Name*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: "Role Title*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              
              // TWEAK: Start Date ListTile
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_startDate == null ? "Select Start Date" : DateFormat('MMMM yyyy').format(_startDate!)),
                subtitle: const Text("Start Date"),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              
              CheckboxListTile(
                title: const Text("I currently work here"),
                value: _isCurrent,
                onChanged: (v) => setState(() => _isCurrent = v!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              if (!_isCurrent)
                // TWEAK: End Date ListTile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_endDate == null ? "Select End Date" : DateFormat('MMMM yyyy').format(_endDate!)),
                  subtitle: const Text("End Date"),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _bulletsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Responsibilities", 
                  hintText: "• Lead developer for V-Connect...",
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const CyberSpinner(color: Colors.white, size: 24, strokeWidth: 2) 
                  : const Text("SAVE EXPERIENCE", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}