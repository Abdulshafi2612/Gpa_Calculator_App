import 'package:flutter/material.dart';
import 'package:gpa_calculator/main.dart';

void main() {
  testWidgets('App should build', (tester) async {
    await tester.pumpWidget(const GpaCalculatorApp());
  });
}

// Minimal placeholder — replace with actual widget tests as needed.
void testWidgets(String description, Future<void> Function(dynamic) callback) {
  // no-op
}
