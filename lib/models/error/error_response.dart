class ErrorResponse {
  final String message;
  final int status;
  final String? timestamp;

  ErrorResponse({
    required this.message,
    required this.status,
    this.timestamp,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        message: json['message'] as String,
        status: json['status'] as int,
        timestamp: json['timestamp'] as String?,
      );
}
