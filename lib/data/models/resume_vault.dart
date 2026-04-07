import 'package:intl/intl.dart';

/// 1. PROJECT MODEL
class Project {
  final String id;
  final String projectName;
  final String description;
  final String techStack;
  final String projectUrl;

  Project({
    required this.id,
    required this.projectName,
    required this.description,
    required this.techStack,
    required this.projectUrl,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] ?? '',
        projectName: json['project_name'] ?? '',
        description: json['description'] ?? '',
        techStack: json['tech_stack'] ?? '',
        projectUrl: json['project_url'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_name': projectName,
        'description': description,
        'tech_stack': techStack,
        'project_url': projectUrl,
      };
}

/// 2. EXPERIENCE MODEL
class Experience {
  final String id;
  final String companyName;
  final String roleTitle;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String bulletPoints;

  Experience({
    required this.id,
    required this.companyName,
    required this.roleTitle,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.bulletPoints,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        id: json['id'] ?? '',
        companyName: json['company_name'] ?? '',
        roleTitle: json['role_title'] ?? '',
        startDate: DateTime.parse(json['start_date']),
        endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        isCurrent: json['is_current'] ?? false,
        bulletPoints: json['bullet_points'] ?? '',
      );

  String get dateRange {
    final start = DateFormat('MMM yyyy').format(startDate);
    final end = isCurrent ? 'Present' : (endDate != null ? DateFormat('MMM yyyy').format(endDate!) : '');
    return "$start - $end";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
        'role_title': roleTitle,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'is_current': isCurrent,
        'bullet_points': bulletPoints,
      };
}

/// 3. EDUCATION MODEL
class Education {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final String startYear;
  final String endYear;

  Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.startYear,
    required this.endYear,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        id: json['id'] ?? '',
        institution: json['institution'] ?? '',
        degree: json['degree'] ?? '',
        fieldOfStudy: json['field_of_study'] ?? '',
        startYear: json['start_year'] ?? '',
        endYear: json['end_year'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'field_of_study': fieldOfStudy,
        'start_year': startYear,
        'end_year': endYear,
      };
}

/// 4. SKILL MODEL
class Skill {
  final String id;
  final String skillName;
  final String category;

  Skill({required this.id, required this.skillName, required this.category});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] ?? '',
        skillName: json['skill_name'] ?? '',
        category: json['category'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'skill_name': skillName,
        'category': category,
      };
}

/// 5. CERTIFICATION MODEL
class Certification {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime? issueDate;
  final String credentialUrl;

  Certification({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    this.issueDate,
    required this.credentialUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        issuingOrganization: json['issuing_organization'] ?? '',
        issueDate: json['issue_date'] != null ? DateTime.parse(json['issue_date']) : null,
        credentialUrl: json['credential_url'] ?? '',
      );

  String get formattedDate => issueDate != null ? DateFormat('MMM yyyy').format(issueDate!) : 'N/A';
}

/// 6. RESUME BLUEPRINT (The selection saved in Go)
class ResumeBlueprint {
  final String id;
  final String resumeName;
  final String targetRole;
  final String summary;
  final List<String> experienceIds;
  final List<String> projectIds;
  final List<String> educationIds;
  final List<String> skillIds;
  final List<String> certificationIds;

  ResumeBlueprint({
    required this.id,
    required this.resumeName,
    required this.targetRole,
    required this.summary,
    required this.experienceIds,
    required this.projectIds,
    required this.educationIds,
    required this.skillIds,
    required this.certificationIds,
  });

  factory ResumeBlueprint.fromJson(Map<String, dynamic> json) => ResumeBlueprint(
        id: json['id'] ?? '',
        resumeName: json['resume_name'] ?? '',
        targetRole: json['target_role'] ?? '',
        summary: json['summary'] ?? '',
        experienceIds: List<String>.from(json['experience_ids'] ?? []),
        projectIds: List<String>.from(json['project_ids'] ?? []),
        educationIds: List<String>.from(json['education_ids'] ?? []),
        skillIds: List<String>.from(json['skill_ids'] ?? []),
        certificationIds: List<String>.from(json['certification_ids'] ?? []),
      );
}

/// 7. COMPILED RESUME (The Full Nested JSON for PDF Generation)
class CompiledResume {
  final ResumeBlueprint details;
  final List<Experience> experiences;
  final List<Project> projects;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Certification> certifications;

  CompiledResume({
    required this.details,
    required this.experiences,
    required this.projects,
    required this.educations,
    required this.skills,
    required this.certifications,
  });

  factory CompiledResume.fromJson(Map<String, dynamic> json) => CompiledResume(
        details: ResumeBlueprint.fromJson(json['resume_details'] ?? {}),
        experiences: (json['experiences'] as List? ?? []).map((e) => Experience.fromJson(e)).toList(),
        projects: (json['projects'] as List? ?? []).map((e) => Project.fromJson(e)).toList(),
        educations: (json['educations'] as List? ?? []).map((e) => Education.fromJson(e)).toList(),
        skills: (json['skills'] as List? ?? []).map((e) => Skill.fromJson(e)).toList(),
        certifications: (json['certifications'] as List? ?? []).map((e) => Certification.fromJson(e)).toList(),
      );
}