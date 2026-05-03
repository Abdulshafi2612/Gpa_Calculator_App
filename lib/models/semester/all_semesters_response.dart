/// Lightweight semester summary returned by `GET /api/semesters` (no subjects).
class AllSemestersResponse {
  final int id;
  final int sequence;
  final double semesterGpa;
  final int semesterCredits;
  final bool active;

  AllSemestersResponse({
    required this.id,
    required this.sequence,
    required this.semesterGpa,
    required this.semesterCredits,
    required this.active,
  });

  factory AllSemestersResponse.fromJson(Map<String, dynamic> json) =>
      AllSemestersResponse(
        id: json['id'] as int,
        sequence: json['sequence'] as int,
        semesterGpa: (json['semesterGpa'] as num).toDouble(),
        semesterCredits: json['semesterCredits'] as int,
        active: json['active'] as bool? ?? true,
      );
}
