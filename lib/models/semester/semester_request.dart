import 'subject_request.dart';

class SemesterRequest {
  final int? sequence;
  final List<SubjectRequest> subjects;

  SemesterRequest({
    this.sequence,
    required this.subjects,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'subjects': subjects.map((s) => s.toJson()).toList(),
    };
    if (sequence != null) json['sequence'] = sequence;
    return json;
  }
}
