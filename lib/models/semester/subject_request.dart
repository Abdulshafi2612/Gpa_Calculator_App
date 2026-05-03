class SubjectRequest {
  final String name;
  final String grade;
  final int credit;
  final int? sequence;

  SubjectRequest({
    required this.name,
    required this.grade,
    required this.credit,
    this.sequence,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'grade': grade,
      'credit': credit,
    };
    if (sequence != null) json['sequence'] = sequence;
    return json;
  }
}
