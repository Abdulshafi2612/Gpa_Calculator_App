import 'subject_response.dart';

class SemesterResponse {
  final int id;
  final int sequence;
  final double semesterGpa;
  final int semesterCredits;
  final bool active;
  final List<SubjectResponse>? subjects;

  SemesterResponse({
    required this.id,
    required this.sequence,
    required this.semesterGpa,
    required this.semesterCredits,
    required this.active,
    this.subjects,
  });

  factory SemesterResponse.fromJson(Map<String, dynamic> json) =>
      SemesterResponse(
        id: json['id'] as int,
        sequence: json['sequence'] as int,
        semesterGpa: (json['semesterGpa'] as num).toDouble(),
        semesterCredits: json['semesterCredits'] as int,
        active: json['active'] as bool? ?? true,
        subjects: json['subjects'] != null
            ? (json['subjects'] as List)
                .map((s) => SubjectResponse.fromJson(s))
                .toList()
            : null,
      );
}
