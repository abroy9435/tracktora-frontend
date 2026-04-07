import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../engine/resume_engine.dart';
import '../../../../data/models/resume_vault.dart';
import '../../../widgets/spinner.dart';
import 'vault_card.dart';

class VaultListComponent extends StatelessWidget {
  final String category;

  const VaultListComponent({
    super.key, 
    required this.category
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      // Dynamically fetches data based on the tab (project, experience, etc.)
      future: ResumeEngine.getVaultItems(category),
      builder: (context, snapshot) {
        // 1. LOADING STATE
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CyberSpinner(size: 40, strokeWidth: 3),
          );
        }

        // 2. ERROR STATE
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text("Unable to load $category vault."),
                TextButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        // 3. DATA EXTRACTION
        final List items = snapshot.data!.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: Text(
              "Your ${category}s vault is currently empty.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        // 4. LIST BUILDING & MODEL MAPPING
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final rawJson = items[index];

            // --- PROJECT MAPPING ---
            if (category == 'project') {
              final p = Project.fromJson(rawJson);
              return VaultCard(
                title: p.projectName,
                subtitle: p.techStack,
                description: p.description,
                category: category,
                id: p.id,
              );
            } 
            
            // --- EXPERIENCE MAPPING ---
            else if (category == 'experience') {
              final e = Experience.fromJson(rawJson);
              return VaultCard(
                title: e.roleTitle,
                subtitle: e.companyName,
                description: e.dateRange,
                category: category,
                id: e.id,
              );
            } 
            
            // --- EDUCATION MAPPING ---
            else if (category == 'education') {
              final edu = Education.fromJson(rawJson);
              return VaultCard(
                title: edu.degree,
                subtitle: edu.institution,
                description: "${edu.fieldOfStudy} (${edu.startYear} - ${edu.endYear})",
                category: category,
                id: edu.id,
              );
            } 
            
            // --- CERTIFICATION MAPPING ---
            else if (category == 'certification') {
              final c = Certification.fromJson(rawJson);
              return VaultCard(
                title: c.name,
                subtitle: c.issuingOrganization,
                description: "Issued: ${c.formattedDate}",
                category: category,
                id: c.id,
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}