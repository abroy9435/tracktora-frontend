import 'package:flutter/material.dart';
import '../../../engine/resume_engine.dart';
import '../../widgets/spinner.dart';
import 'widgets/vault_list_component.dart';
import 'widgets/add_project_sheet.dart';
import 'widgets/add_experience_sheet.dart';
import 'widgets/add_education_sheet.dart';
import 'widgets/add_certification_sheet.dart';
import 'resume_builder_wizard.dart';
import 'resume_preview_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    // Two main sections: Master Vault (Library) and My Resumes (Generated)
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  /// Refreshes the UI after a new item is added to Supabase
  void _openAddSheet(Widget sheet) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => sheet,
    );

    if (result == true && mounted) {
      setState(() {}); // Triggers a rebuild of FutureBuilders
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CAREER HUB', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        bottom: TabBar(
          controller: _mainTabController,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          tabs: const [
            Tab(text: "MASTER VAULT"),
            Tab(text: "MY RESUMES"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildMasterVault(theme),
          _buildMyResumes(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // CRITICAL: Unique tag prevents the 'Multiple Heroes' crash
        heroTag: 'vault_hub_main_fab', 
        onPressed: () => _showActionMenu(context),
        label: const Text("ACTION"),
        icon: const Icon(Icons.bolt_outlined),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  /// TAB 1: THE MASTER VAULT (Category view)
  Widget _buildMasterVault(ThemeData theme) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "PROJECTS"),
                Tab(text: "EXPERIENCE"),
                Tab(text: "EDUCATION"),
                Tab(text: "CERTS"),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                VaultListComponent(category: 'project'),
                VaultListComponent(category: 'experience'),
                VaultListComponent(category: 'education'),
                VaultListComponent(category: 'certification'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TAB 2: MY RESUMES (Saved PDF Blueprints)
  Widget _buildMyResumes(ThemeData theme) {
    return FutureBuilder(
      future: ResumeEngine.getSavedResumes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CyberSpinner(size: 40));
        }

        final List resumes = snapshot.data?.data ?? [];

        if (resumes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text("No resumes generated yet.", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: _launchBuilder,
                  child: const Text("Assemble Your First Resume"),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resumes.length,
          itemBuilder: (context, index) {
            final res = resumes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(res['resume_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(res['target_role']),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResumePreviewScreen(resumeId: res['id']),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// BOTTOM MENU: Access to all "Add" forms and the Wizard
  void _showActionMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: Text("ADD TO MASTER VAULT", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.blue),
              title: const Text("Project"),
              onTap: () {
                Navigator.pop(context);
                _openAddSheet(const AddProjectSheet());
              },
            ),
            ListTile(
              leading: const Icon(Icons.work_outline, color: Colors.orange),
              title: const Text("Experience"),
              onTap: () {
                Navigator.pop(context);
                _openAddSheet(const AddExperienceSheet());
              },
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined, color: Colors.cyan),
              title: const Text("Education"),
              onTap: () {
                Navigator.pop(context);
                _openAddSheet(const AddEducationSheet());
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_outlined, color: Colors.green),
              title: const Text("Certification"),
              onTap: () {
                Navigator.pop(context);
                _openAddSheet(const AddCertificationSheet());
              },
            ),
            const Divider(height: 32),
            ListTile(
              tileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
              title: const Text("Launch Resume Builder", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              onTap: () {
                Navigator.pop(context);
                _launchBuilder();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// NAVIGATION: Launches the 4-step wizard
  void _launchBuilder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResumeBuilderWizard()),
    );

    if (result == true && mounted) {
      setState(() {});
      _mainTabController.animateTo(1); // Auto-slide to 'My Resumes'
    }
  }
}