class UserResponse {
  final int id;
  final String name;
  final String email;
  final double totalGpa;
  final int totalCredits;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.totalGpa,
    required this.totalCredits,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        totalGpa: (json['totalGpa'] as num).toDouble(),
        totalCredits: json['totalCredits'] as int,
      );
}
