import 'package:flutter/material.dart';

import '../core/network/api_exceptions.dart';

/// Converts an exception into a user-friendly message and displays it.
class ErrorHandler {
  ErrorHandler._();

  /// Show a [SnackBar] with a readable error message.
  static void showError(BuildContext context, dynamic error) {
    final message = _extractMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show a success [SnackBar].
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String _extractMessage(dynamic error) {
    if (error is ApiException) return error.message;
    if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
    return 'An unexpected error occurred.';
  }
}
