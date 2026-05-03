import 'package:flutter/material.dart';

import '../../models/semester/semester_response.dart';
import '../../services/semester_api_service.dart';
import '../../utils/error_handler.dart';

class SemesterDetailsScreen extends StatefulWidget {
  final int semesterId;

  const SemesterDetailsScreen({super.key, required this.semesterId});

  @override
  State<SemesterDetailsScreen> createState() => _SemesterDetailsScreenState();
}

class _SemesterDetailsScreenState extends State<SemesterDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _semesterService = SemesterApiService();
  SemesterResponse? _semester;
  bool _isLoading = true;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadSemester();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSemester() async {
    setState(() => _isLoading = true);
    try {
      final semester =
          await _semesterService.getSemesterById(widget.semesterId);
      if (!mounted) return;
      setState(() => _semester = semester);
      _animController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive() async {
    try {
      await _semesterService.toggleSemesterActive(widget.semesterId);
      if (!mounted) return;
      _loadSemester();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _semester?.active ?? true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _semester != null
              ? 'Semester ${_semester!.sequence}'
              : 'Semester Details',
          style: const TextStyle(
            fontFamily: 'BauhausStd',
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_semester != null) ...[
            // Toggle active
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isActive ? Icons.visibility : Icons.visibility_off,
                  key: ValueKey('active_$isActive'),
                  color: Colors.white,
                ),
              ),
              tooltip: isActive ? 'Deactivate Semester' : 'Activate Semester',
              onPressed: _toggleActive,
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Semester',
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  '/edit-semester',
                  arguments: widget.semesterId,
                );
                _loadSemester();
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _semester == null
              ? const Center(child: Text('Semester not found'))
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Untitled-1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.85),
                    child: _buildBody(),
                  ),
                ),
    );
  }

  Widget _buildBody() {
    final s = _semester!;
    final subjects = s.subjects ?? [];
    final isActive = s.active;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Active status banner ────────────────
        if (!isActive)
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animController,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This semester is deactivated and excluded from CGPA',
                      style: TextStyle(
                        fontFamily: 'BauhausStd',
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Summary Card (animated) ────────────────
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _animController,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue.withValues(alpha: 0.85)
                  : Colors.grey.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('GPA', s.semesterGpa.toStringAsFixed(2)),
                Container(width: 1, height: 50, color: Colors.white38),
                _stat('Credits', s.semesterCredits.toString()),
                Container(width: 1, height: 50, color: Colors.white38),
                _stat('Subjects', subjects.length.toString()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Subject header ────────────────────────
        const Text(
          'Subjects',
          style: TextStyle(
            fontFamily: 'BauhausStd',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // ── Subject cards (staggered animation) ───
        if (subjects.isEmpty)
          const Center(child: Text('No subjects'))
        else
          ...subjects.asMap().entries.map((entry) {
            final i = entry.key;
            final sub = entry.value;
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animController,
                  curve: Interval(
                    0.2 + (i * 0.08).clamp(0.0, 0.6),
                    0.6 + (i * 0.08).clamp(0.0, 0.4),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: Interval(
                      0.2 + (i * 0.08).clamp(0.0, 0.6),
                      0.6 + (i * 0.08).clamp(0.0, 0.4),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        '${sub.sequence}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      sub.name,
                      style: const TextStyle(
                        fontFamily: 'BauhausStd',
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('Credit: ${sub.credit}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _gradeColor(sub.grade),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sub.grade,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'BauhausStd',
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'BauhausStd',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _gradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    if (grade.startsWith('D')) return Colors.deepOrange;
    if (grade == 'F') return Colors.red;
    return Colors.grey;
  }
}
