class CgpaResponse {
  final double cgpa;
  final int totalCredits;
  final int semesterCount;

  CgpaResponse({
    required this.cgpa,
    required this.totalCredits,
    required this.semesterCount,
  });

  factory CgpaResponse.fromJson(Map<String, dynamic> json) => CgpaResponse(
        cgpa: (json['cgpa'] as num).toDouble(),
        totalCredits: json['totalCredits'] as int,
        semesterCount: json['semesterCount'] as int,
      );
}
