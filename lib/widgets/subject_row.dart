import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Grade-to-GPA mapping for local semester calculation.
const Map<String, double> gradePointMap = {
  '-': 0.0,
  'A+': 4.0,
  'A': 4.0,
  'A-': 3.7,
  'B+': 3.3,
  'B': 3.0,
  'B-': 2.7,
  'C+': 2.3,
  'C': 2.0,
  'C-': 1.7,
  'D+': 1.3,
  'D': 1.0,
  'F': 0.0,
};

/// Available grade values — matches the backend grade mapping.
const List<String> gradeValues = [
  '-', 'A+', 'A', 'A-', 'B+', 'B', 'B-',
  'C+', 'C', 'C-', 'D+', 'D', 'F',
];

/// A single row for entering subject data: name, grade, credit.
/// Uses underline-style fields matching the original design.
class SubjectRow extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController creditController;
  final String grade;
  final ValueChanged<String> onGradeChanged;

  const SubjectRow({
    super.key,
    required this.index,
    required this.nameController,
    required this.creditController,
    required this.grade,
    required this.onGradeChanged,
  });

  String? _validateRow(String? value) {
    final name = nameController.text.trim();
    final credit = creditController.text.trim();
    final g = grade;

    final isCompletelyEmpty = name.isEmpty && credit.isEmpty && g == '-';
    final isCompletelyFilled = name.isNotEmpty && credit.isNotEmpty && g != '-';

    if (!isCompletelyEmpty && !isCompletelyFilled) {
      return 'Incomplete';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject name — underline style
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Subject ${index + 1}',
            ),
            validator: _validateRow,
          ),
        ),
        // Grade dropdown — plain style
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DropdownButton<String>(
            value: grade,
            items: gradeValues
                .map((g) => DropdownMenuItem<String>(
                      value: g,
                      child: Text(g),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) onGradeChanged(v);
            },
          ),
        ),
        // Credits — underline style
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: creditController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Credits',
            ),
            validator: (v) {
              final rowErr = _validateRow(v);
              if (rowErr != null) return rowErr;
              if (v != null && v.isNotEmpty && (int.tryParse(v) ?? 0) <= 0) {
                return '> 0';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
