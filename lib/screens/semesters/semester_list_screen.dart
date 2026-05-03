import 'package:flutter/material.dart';

import '../../models/semester/all_semesters_response.dart';
import '../../services/semester_api_service.dart';
import '../../utils/error_handler.dart';

class SemesterListScreen extends StatefulWidget {
  const SemesterListScreen({super.key});

  @override
  State<SemesterListScreen> createState() => _SemesterListScreenState();
}

class _SemesterListScreenState extends State<SemesterListScreen> {
  final _semesterService = SemesterApiService();
  List<AllSemestersResponse> _semesters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    setState(() => _isLoading = true);
    try {
      final semesters = await _semesterService.getAllSemesters();
      semesters.sort((a, b) => a.sequence.compareTo(b.sequence));
      if (!mounted) return;
      setState(() => _semesters = semesters);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive(AllSemestersResponse semester) async {
    try {
      await _semesterService.toggleSemesterActive(semester.id);
      if (!mounted) return;
      _loadSemesters();
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    }
  }

  Future<void> _deleteSemester(AllSemestersResponse semester) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Semester'),
        content: const Text(
            'Are you sure you want to delete this semester?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _semesterService.deleteSemester(semester.id);
        if (!mounted) return;
        ErrorHandler.showSuccess(context, 'Semester deleted');
        _loadSemesters();
      } catch (e) {
        if (!mounted) return;
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Semesters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w300,
            fontFamily: 'BauhausStd',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Untitled-1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.8),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _semesters.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadSemesters,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _semesters.length,
                        itemBuilder: (context, index) {
                          final s = _semesters[index];
                          return _AnimatedSemesterCard(
                            index: index,
                            child: _buildSemesterCard(s),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await Navigator.of(context).pushNamed('/add-semester');
          _loadSemesters();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No semesters yet',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'BauhausStd',
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first semester',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(AllSemestersResponse s) {
    final isActive = s.active;

    return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .pushNamed('/semester-details', arguments: s.id);
        _loadSemesters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blue.withValues(alpha: 0.85)
              : Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isActive ? Colors.black12 : Colors.black.withValues(alpha: 0.05),
              offset: const Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isActive
                    ? Icons.format_list_numbered_outlined
                    : Icons.pause_circle_outline,
                key: ValueKey(isActive),
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester ${s.sequence}',
                    style: TextStyle(
                      fontFamily: 'BauhausStd',
                      color: Colors.white,
                      fontSize: 22,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                      decorationColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Credits: ${s.semesterCredits}',
                    style: const TextStyle(
                      fontFamily: 'BauhausStd',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (!isActive)
                    const Text(
                      'Excluded from CGPA',
                      style: TextStyle(
                        fontFamily: 'BauhausStd',
                        color: Colors.white60,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'GPA',
                  style: TextStyle(
                    fontFamily: 'BauhausStd',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  s.semesterGpa.toStringAsFixed(2),
                  style: TextStyle(
                    fontFamily: 'BauhausStd',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    decoration: isActive ? null : TextDecoration.lineThrough,
                    decorationColor: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            // ── Toggle active button ────────────────
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isActive
                      ? Icons.visibility
                      : Icons.visibility_off,
                  key: ValueKey('toggle_$isActive'),
                  color: isActive ? Colors.white70 : Colors.white38,
                  size: 28,
                ),
              ),
              tooltip: isActive ? 'Deactivate' : 'Activate',
              onPressed: () => _toggleActive(s),
            ),
            // ── Delete button ───────────────────────
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white38, size: 28),
              onPressed: () => _deleteSemester(s),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animates each semester card sliding in from the right with a staggered delay.
class _AnimatedSemesterCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedSemesterCard({required this.index, required this.child});

  @override
  State<_AnimatedSemesterCard> createState() => _AnimatedSemesterCardState();
}

class _AnimatedSemesterCardState extends State<_AnimatedSemesterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
