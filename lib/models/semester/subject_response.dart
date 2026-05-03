class SubjectResponse {
  final int id;
  final String name;
  final String grade;
  final int credit;
  final int sequence;

  SubjectResponse({
    required this.id,
    required this.name,
    required this.grade,
    required this.credit,
    required this.sequence,
  });

  factory SubjectResponse.fromJson(Map<String, dynamic> json) =>
      SubjectResponse(
        id: json['id'] as int,
        name: json['name'] as String,
        grade: json['grade'] as String,
        credit: json['credit'] as int,
        sequence: json['sequence'] as int,
      );
}
