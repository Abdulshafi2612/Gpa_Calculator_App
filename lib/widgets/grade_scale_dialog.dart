import 'package:flutter/material.dart';

/// Reusable dialog showing the 4.0 GPA grade scale.
/// Matches the old app's info dialog style.
void showGradeScaleDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        '4.0 Scale',
        style: TextStyle(
          fontSize: 25,
          fontFamily: 'BauhausStd',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Grade',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(
                'A+\nA\nA-\nB+\nB\nB-\nC+\nC\nC-\nD+\nD\nF',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'BauhausStd'),
              ),
            ],
          ),
          SizedBox(width: 30),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Points',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(
                '4.0\n4.0\n3.7\n3.3\n3.0\n2.7\n2.3\n2.0\n1.7\n1.3\n1.0\n0.0',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'BauhausStd'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
