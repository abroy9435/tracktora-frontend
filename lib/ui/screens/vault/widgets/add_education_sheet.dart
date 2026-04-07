import 'package:flutter/material.dart';
import '../../../../engine/resume_engine.dart';
import '../../../widgets/spinner.dart';

class AddEducationSheet extends StatefulWidget {
  const AddEducationSheet({super.key});

  @override
  State<AddEducationSheet> createState() => _AddEducationSheetState();
}

class _AddEducationSheetState extends State<AddEducationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ResumeEngine.addToVault('education', {
        'institution': _institutionController.text.trim(),
        'degree': _degreeController.text.trim(),
        'field_of_study': _fieldController.text.trim(),
        'start_year': _startYearController.text.trim(),
        'end_year': _endYearController.text.trim(),
      });

      if (mounted && response.statusCode == 201) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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
              Text("ADD EDUCATION", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: "Institution*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: "Degree (e.g. B.Tech)*", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(labelText: "Field of Study", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Start Year", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "End Year", border: OutlineInputBorder()),
                    ),
                  ),
                ],
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
      ),
    );
  }
}