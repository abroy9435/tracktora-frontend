import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/resume_vault.dart';

class PdfGenerator {
  static Future<void> generateAndSave(CompiledResume resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- NAME ---
            pw.Text(
              "VINAYAK DUTTA BHARDWAJ",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),

            // --- ROLE ---
            pw.Text(
              resume.details.targetRole.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue800, // No 'const' allowed here
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300, height: 20),

            // --- SUMMARY ---
            if (resume.details.summary.isNotEmpty) ...[
              _sectionHeader("PROFESSIONAL SUMMARY"),
              pw.Text(
                resume.details.summary,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4),
              ),
              pw.SizedBox(height: 15),
            ],

            // --- EXPERIENCE ---
            if (resume.experiences.isNotEmpty) ...[
              _sectionHeader("EXPERIENCE"),
              ...resume.experiences.map((e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(e.roleTitle,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold, fontSize: 11)),
                            pw.Text(e.dateRange,
                                style: const pw.TextStyle(
                                    fontSize: 10, color: PdfColors.grey)),
                          ],
                        ),
                        pw.Text(
                          e.companyName,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.blue700, // Color logic = No const
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(e.bulletPoints,
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 10),
            ],

            // --- PROJECTS ---
            if (resume.projects.isNotEmpty) ...[
              _sectionHeader("KEY PROJECTS"),
              ...resume.projects.map((p) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(p.projectName,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text(
                          "Tech: ${p.techStack}",
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(p.description,
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 10),
            ],

            // --- CERTIFICATIONS ---
            if (resume.certifications.isNotEmpty) ...[
              _sectionHeader("CERTIFICATIONS"),
              ...resume.certifications.map((c) => pw.Bullet(
                    text:
                        "${c.name} - ${c.issuingOrganization} (${c.formattedDate})",
                    style: const pw.TextStyle(fontSize: 10),
                  )),
            ],
          ];
        },
      ),
    );

    // Triggers the system "Save As" / Print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${resume.details.resumeName.replaceAll(' ', '_')}_Resume.pdf',
    );
  }

  // HELPER: Section Titles
  static pw.Widget _sectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, top: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800, // Evaluated at runtime, so no 'const'
        ),
      ),
    );
  }
}