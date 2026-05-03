import 'package:flutter/material.dart';

import '../../models/semester/semester_request.dart';
import '../../models/semester/semester_response.dart';
import '../../models/semester/subject_request.dart';
import '../../services/semester_api_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/grade_scale_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/subject_row.dart';

class EditSemesterScreen extends StatefulWidget {
  final int semesterId;

  const EditSemesterScreen({super.key, required this.semesterId});

  @override
  State<EditSemesterScreen> createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends State<EditSemesterScreen> {
  static const _maxSubjects = 10;
  final _semesterService = SemesterApiService();

  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _nameControllers;
  late final List<TextEditingController> _creditControllers;
  late List<String> _grades;

  SemesterResponse? _semester;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameControllers =
        List.generate(_maxSubjects, (_) => TextEditingController());
    _creditControllers =
        List.generate(_maxSubjects, (_) => TextEditingController());
    _grades = List.filled(_maxSubjects, '-');
    _loadSemester();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _creditControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSemester() async {
    setState(() => _isLoading = true);
    try {
      final semester =
          await _semesterService.getSemesterById(widget.semesterId);
      if (!mounted) return;

      setState(() {
        _semester = semester;
        final subjects = semester.subjects ?? [];
        for (int i = 0; i < _maxSubjects; i++) {
          if (i < subjects.length) {
            _nameControllers[i].text = subjects[i].name;
            _creditControllers[i].text = subjects[i].credit.toString();
            _grades[i] = subjects[i].grade;
          } else {
            _nameControllers[i].clear();
            _creditControllers[i].clear();
            _grades[i] = '-';
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<SubjectRequest> _buildSubjects() {
    final subjects = <SubjectRequest>[];
    int seq = 1;
    for (int i = 0; i < _maxSubjects; i++) {
      final name = _nameControllers[i].text.trim();
      final credit = int.tryParse(_creditControllers[i].text.trim()) ?? 0;
      final grade = _grades[i];

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

    final hasZeroCredit = subjects.any((s) => s.credit <= 0 && s.grade != '-');
    if (hasZeroCredit) {
      ErrorHandler.showError(
          context, Exception('Each graded subject must have credits > 0'));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _semesterService.updateSemester(
        widget.semesterId,
        SemesterRequest(subjects: subjects),
      );

      if (!mounted) return;
      ErrorHandler.showSuccess(context, 'Semester updated!');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _reset() {
    if (_semester == null) return;
    setState(() {
      final subjects = _semester!.subjects ?? [];
      for (int i = 0; i < _maxSubjects; i++) {
        if (i < subjects.length) {
          _nameControllers[i].text = subjects[i].name;
          _creditControllers[i].text = subjects[i].credit.toString();
          _grades[i] = subjects[i].grade;
        } else {
          _nameControllers[i].clear();
          _creditControllers[i].clear();
          _grades[i] = '-';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            _semester != null
                ? 'Edit Semester ${_semester!.sequence}'
                : 'Edit Semester',
            style: const TextStyle(
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LoadingOverlay(
                isLoading: _isSaving,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Untitled-1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // ── Semester info ──────────────────
                          if (_semester != null) ...[
                            Text(
                              'Semester GPA: ${_semester!.semesterGpa.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'BauhausStd',
                              ),
                            ),
                            Text(
                              'Credits: ${_semester!.semesterCredits}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'BauhausStd',
                              ),
                            ),
                          ],

                          // ── Subject list ───────────────────
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
                                    _formKey.currentState?.validate();
                                  },
                                ),
                              ),
                            ),
                          ),

                          // ── Action buttons ─────────────────
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _saveSemester,
                                child: const Text(
                                  'SAVE',
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
    );
  }
}
