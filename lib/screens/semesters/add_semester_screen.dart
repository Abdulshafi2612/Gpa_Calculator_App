import 'package:flutter/material.dart';

import '../../models/semester/semester_request.dart';
import '../../models/semester/subject_request.dart';
import '../../services/semester_api_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/grade_scale_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/subject_row.dart';

class AddSemesterScreen extends StatefulWidget {
  const AddSemesterScreen({super.key});

  @override
  State<AddSemesterScreen> createState() => _AddSemesterScreenState();
}

class _AddSemesterScreenState extends State<AddSemesterScreen>
    with SingleTickerProviderStateMixin {
  static const _maxSubjects = 10;
  final _semesterService = SemesterApiService();
  final _sequenceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _nameControllers;
  late final List<TextEditingController> _creditControllers;
  late final List<String> _grades;

  bool _isLoading = false;

  // Live-calculated values
  double _semesterGpa = 0.0;
  int _semesterCredits = 0;

  // Animation
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameControllers =
        List.generate(_maxSubjects, (_) => TextEditingController());
    _creditControllers =
        List.generate(_maxSubjects, (_) => TextEditingController());
    _grades = List.filled(_maxSubjects, '-');

    // Listen for credit changes to recalculate live
    for (final c in _creditControllers) {
      c.addListener(_calculateLiveGpa);
    }

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _sequenceController.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _creditControllers) {
      c.removeListener(_calculateLiveGpa);
      c.dispose();
    }
    super.dispose();
  }

  /// Recalculate GPA and credits locally whenever grade/credit changes.
  void _calculateLiveGpa() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (int i = 0; i < _maxSubjects; i++) {
      final grade = _grades[i];
      if (grade == '-') continue;
      final credit = double.tryParse(_creditControllers[i].text.trim()) ?? 0;
      if (credit <= 0) continue;

      final gradeValue = gradePointMap[grade] ?? 0.0;
      totalPoints += gradeValue * credit;
      totalCredits += credit;
    }

    setState(() {
      _semesterGpa = totalCredits == 0 ? 0 : totalPoints / totalCredits;
      _semesterCredits = totalCredits.toInt();
    });
  }

  /// Build the list of non-empty subject requests.
  List<SubjectRequest> _buildSubjects() {
    final subjects = <SubjectRequest>[];
    int seq = 1;
    for (int i = 0; i < _maxSubjects; i++) {
      final name = _nameControllers[i].text.trim();
      final credit = int.tryParse(_creditControllers[i].text.trim()) ?? 0;
      final grade = _grades[i];

      // Skip empty rows.
      if (name.isEmpty && grade == '-' && credit == 0) continue;

      subjects.add(SubjectRequest(
        name: name.isEmpty ? 'Subject $seq' : name,
        grade: grade,
        credit: credit,
        sequence: seq,
      ));
      seq++;
    }
    return subjects;
  }

  Future<void> _saveSemester() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subjects = _buildSubjects();

    if (subjects.isEmpty) {
      ErrorHandler.showError(context, Exception("Semester can't be empty"));
      return;
    }

    // Validate credits.
    final hasZeroCredit = subjects.any((s) => s.credit <= 0 && s.grade != '-');
    if (hasZeroCredit) {
      ErrorHandler.showError(
          context, Exception('Each graded subject must have credits > 0'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final seqText = _sequenceController.text.trim();
      final sequence = seqText.isNotEmpty ? int.tryParse(seqText) : null;

      await _semesterService.createSemester(
        SemesterRequest(sequence: sequence, subjects: subjects),
      );

      if (!mounted) return;
      ErrorHandler.showSuccess(context, 'Semester added!');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reset() {
    setState(() {
      _sequenceController.clear();
      for (int i = 0; i < _maxSubjects; i++) {
        _nameControllers[i].clear();
        _creditControllers[i].clear();
        _grades[i] = '-';
      }
      _semesterGpa = 0.0;
      _semesterCredits = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Add Semester',
            style: TextStyle(
              fontFamily: 'BauhausStd',
              fontSize: 26,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              onPressed: () => showGradeScaleDialog(context),
              icon: const Icon(Icons.info, color: Colors.white, size: 30),
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Untitled-1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.white.withValues(alpha: 0.95),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Live GPA/Credits header ──────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey('$_semesterGpa-$_semesterCredits'),
                          children: [
                            Text(
                              'Semester GPA: ${_semesterGpa.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'BauhausStd',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Credits: $_semesterCredits',
                              style: const TextStyle(
                                fontFamily: 'BauhausStd',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Subject list ─────────────────────
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: ListView.builder(
                            itemCount: _maxSubjects,
                            itemBuilder: (context, i) => SubjectRow(
                              index: i,
                              nameController: _nameControllers[i],
                              creditController: _creditControllers[i],
                              grade: _grades[i],
                              onGradeChanged: (g) {
                                setState(() => _grades[i] = g);
                                _calculateLiveGpa();
                                // trigger validation when grade changes so error hides
                                _formKey.currentState?.validate();
                              },
                            ),
                          ),
                        ),
                      ),

                      // ── Action buttons ───────────────────
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _saveSemester,
                            child: const Text(
                              'CALCULATE',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'BauhausStd',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _reset,
                            child: const Text(
                              'RESET',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'BauhausStd',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
