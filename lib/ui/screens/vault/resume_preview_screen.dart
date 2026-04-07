import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../engine/resume_engine.dart';
import '../../../data/models/resume_vault.dart';
import '../../widgets/spinner.dart';

class ResumePreviewScreen extends StatefulWidget {
  final String resumeId;

  const ResumePreviewScreen({super.key, required this.resumeId});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  late Future<CompiledResume> _compiledFuture;
  CompiledResume? _resumeData;

  @override
  void initState() {
    super.initState();
    _compiledFuture = _fetchFullResume();
  }

  Future<CompiledResume> _fetchFullResume() async {
    final response = await ResumeEngine.getCompiledResume(widget.resumeId);
    final data = CompiledResume.fromJson(response.data);
    setState(() => _resumeData = data);
    return data;
  }

  Future<void> _generateAndDownloadPdf(CompiledResume resume) async {
    final pdf = pw.Document();

    final boldStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12);
    final bodyStyle = const pw.TextStyle(fontSize: 10);
    final headerStyle = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Text("VINAYAK DUTTA BHARDWAJ", style: headerStyle),
          pw.SizedBox(height: 4),
          pw.Text(resume.details.targetRole.toUpperCase(),
              style: pw.TextStyle(fontSize: 14, color: PdfColors.blue900, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 1, color: PdfColors.grey300, height: 25),

          if (resume.details.summary.isNotEmpty) ...[
            _pdfSectionTitle("PROFESSIONAL SUMMARY"),
            // FIX: Changed lineHeight to lineSpacing
            pw.Text(resume.details.summary, style: bodyStyle.copyWith(lineSpacing: 1.4)),
            pw.SizedBox(height: 20),
          ],

          if (resume.experiences.isNotEmpty) ...[
            _pdfSectionTitle("WORK EXPERIENCE"),
            ...resume.experiences.map((e) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(e.roleTitle, style: boldStyle),
                        pw.Text(e.dateRange, style: bodyStyle.copyWith(color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text(e.companyName,
                        style: bodyStyle.copyWith(color: PdfColors.blue700, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(e.bulletPoints, style: bodyStyle),
                    pw.SizedBox(height: 12),
                  ],
                )),
          ],

          if (resume.projects.isNotEmpty) ...[
            _pdfSectionTitle("KEY PROJECTS"),
            ...resume.projects.map((p) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(p.projectName, style: boldStyle),
                    pw.Text("Tech Stack: ${p.techStack}",
                        style: bodyStyle.copyWith(fontStyle: pw.FontStyle.italic, fontSize: 9)),
                    pw.SizedBox(height: 2),
                    pw.Text(p.description, style: bodyStyle),
                    pw.SizedBox(height: 12),
                  ],
                )),
          ],

          if (resume.certifications.isNotEmpty) ...[
            _pdfSectionTitle("CERTIFICATIONS"),
            ...resume.certifications.map((c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text("• ${c.name} — ${c.issuingOrganization} (${c.formattedDate})", style: bodyStyle),
                )),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${resume.details.resumeName.replaceAll(' ', '_')}.pdf',
    );
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, top: 10),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("RESUME PREVIEW"),
        actions: [
          if (_resumeData != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: "Download PDF",
              onPressed: () => _generateAndDownloadPdf(_resumeData!),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<CompiledResume>(
        future: _compiledFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CyberSpinner(size: 50));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error generating preview."));
          }

          final resume = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("VINAYAK DUTTA BHARDWAJ",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(resume.details.targetRole.toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(height: 40, thickness: 1.2),

                    if (resume.details.summary.isNotEmpty) ...[
                      _sectionTitle("PROFESSIONAL SUMMARY"),
                      Text(resume.details.summary, style: const TextStyle(height: 1.6, fontSize: 13)),
                      const SizedBox(height: 30),
                    ],

                    if (resume.experiences.isNotEmpty) ...[
                      _sectionTitle("EXPERIENCE"),
                      ...resume.experiences.map((e) => _buildExperienceCard(e)),
                      const SizedBox(height: 10),
                    ],

                    if (resume.projects.isNotEmpty) ...[
                      _sectionTitle("KEY PROJECTS"),
                      ...resume.projects.map((p) => _buildProjectCard(p)),
                      const SizedBox(height: 10),
                    ],

                    if (resume.certifications.isNotEmpty) ...[
                      _sectionTitle("CERTIFICATIONS"),
                      ...resume.certifications.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text("${c.name} — ${c.issuingOrganization} (${c.formattedDate})")),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
    );
  }

  Widget _buildExperienceCard(Experience e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.roleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(e.dateRange, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(e.companyName, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Text(e.bulletPoints, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text("Tech: ${p.techStack}",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(p.description, style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87)),
        ],
      ),
    );
  }
}