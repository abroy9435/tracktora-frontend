import 'package:flutter/material.dart';
import '../../../engine/resume_engine.dart';
import '../../../data/models/resume_vault.dart';
import '../../widgets/spinner.dart';

class ResumeBuilderWizard extends StatefulWidget {
  const ResumeBuilderWizard({super.key});

  @override
  State<ResumeBuilderWizard> createState() => _ResumeBuilderWizardState();
}

class _ResumeBuilderWizardState extends State<ResumeBuilderWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Selection Lists
  final List<String> _selectedExpIds = [];
  final List<String> _selectedProjectIds = [];
  final List<String> _selectedCertIds = [];
  
  // Controllers for the final step
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _summaryController = TextEditingController();

  // Unified fetcher for the vault items
  Future<List<T>> _fetch<T>(String cat, T Function(Map<String, dynamic>) map) async {
    final res = await ResumeEngine.getVaultItems(cat);
    return (res.data as List).map((i) => map(i as Map<String, dynamic>)).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _roleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () => Navigator.pop(context)
        ),
        title: Text(
          "STEP ${_currentStep + 1} OF 4", 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping to force button use
        children: [
          _buildSelectionList<Experience>(
            "SELECT EXPERIENCE",
            () => _fetch('experience', (j) => Experience.fromJson(j)),
            _selectedExpIds,
            (i) => i.roleTitle,
            (i) => i.companyName,
          ),
          _buildSelectionList<Project>(
            "SELECT PROJECTS",
            () => _fetch('project', (j) => Project.fromJson(j)),
            _selectedProjectIds,
            (i) => i.projectName,
            (i) => i.techStack,
          ),
          _buildSelectionList<Certification>(
            "SELECT CERTS",
            () => _fetch('certification', (j) => Certification.fromJson(j)),
            _selectedCertIds,
            (i) => i.name,
            (i) => i.issuingOrganization,
          ),
          _buildFinalForm(),
        ],
      ),
      bottomNavigationBar: _buildNav(Theme.of(context)),
    );
  }

  // Generic List Builder for Steps 1-3
  Widget _buildSelectionList<T>(
    String title,
    Future<List<T>> Function() future,
    List<String> selectionList,
    String Function(T) mainText,
    String Function(T) subText,
  ) {
    return FutureBuilder<List<T>>(
      future: future(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CyberSpinner(size: 40));
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }

        final items = snapshot.data ?? [];
        
        return ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              );
            }
            
            final item = items[index - 1];
            final dynamic typed = item;
            final isSelected = selectionList.contains(typed.id);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (v) {
                setState(() {
                  v! ? selectionList.add(typed.id) : selectionList.remove(typed.id);
                });
              },
              title: Text(mainText(item), style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subText(item)),
            );
          },
        );
      },
    );
  }

  Widget _buildFinalForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("FINAL TOUCHES", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Tailor this version for the specific job description.", style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController, 
          decoration: const InputDecoration(labelText: "Resume Version Name", border: OutlineInputBorder())
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _roleController, 
          decoration: const InputDecoration(labelText: "Target Role Title", border: OutlineInputBorder())
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _summaryController, 
          maxLines: 5, 
          decoration: const InputDecoration(labelText: "Tailored Summary", border: OutlineInputBorder())
        ),
      ],
    );
  }

  Widget _buildNav(ThemeData theme) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _prev, // Updated to match the method name
            child: Text(_currentStep == 0 ? "CANCEL" : "BACK")
          ),
          SizedBox(
            width: 140, // Fixed width prevents infinite layout errors
            child: FilledButton(
              onPressed: _isSubmitting ? null : _next, // Updated to match the method name
              child: _isSubmitting 
                ? const CyberSpinner(size: 20, color: Colors.white) 
                : Text(_currentStep == 3 ? "FINISH" : "NEXT"),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC METHODS ---

  void _next() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
      setState(() => _currentStep--);
    }
  }

  void _finish() async {
    // Basic Validation
    if (_nameController.text.isEmpty || _roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a name and target role."))
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await ResumeEngine.buildResume({
        "resume_name": _nameController.text.trim(),
        "target_role": _roleController.text.trim(),
        "summary": _summaryController.text.trim(),
        "experience_ids": _selectedExpIds,
        "project_ids": _selectedProjectIds,
        "certification_ids": _selectedCertIds,
      });
      
      if (mounted && response.statusCode == 201) {
        Navigator.pop(context, true); // Return true to refresh the list in VaultScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error building resume: $e"))
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}