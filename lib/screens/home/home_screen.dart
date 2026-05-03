import 'package:flutter/material.dart';

import '../../core/storage/token_storage.dart';
import '../../models/gpa/cgpa_response.dart';
import '../../models/user/user_response.dart';
import '../../services/gpa_api_service.dart';
import '../../services/user_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _gpaService = GpaApiService();
  final _userService = UserApiService();

  UserResponse? _user;
  CgpaResponse? _cgpa;
  bool _isLoading = true;

  // Animations
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getCurrentUser();
      final cgpa = await _gpaService.getCgpa();
      if (!mounted) return;
      setState(() {
        _user = user;
        _cgpa = cgpa;
      });
      _animController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await TokenStorage().clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GPA Calculator',
              style: TextStyle(
                fontFamily: 'BauhausStd',
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            if (_user != null)
              Text(
                _user!.name,
                style: const TextStyle(
                  fontFamily: 'BauhausStd',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Untitled-1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.white.withValues(alpha: 0.4),
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      const SizedBox(height: 24),

                      // ── CGPA Badge (animated scale) ────────
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: Container(
                              width: 230,
                              height: 230,
                              color: Colors.blue.withValues(alpha: 0.8),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Your Overall',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BauhausStd',
                                        fontSize: 25,
                                      ),
                                    ),
                                    const Text(
                                      'GPA Is',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BauhausStd',
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      (_cgpa?.cgpa ?? 0.0).toStringAsFixed(2),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BauhausStd',
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Credits: ${_cgpa?.totalCredits ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BauhausStd',
                                        fontSize: 25,
                                      ),
                                    ),
                                    if (_cgpa != null)
                                      Text(
                                        'Semesters: ${_cgpa!.semesterCount}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'BauhausStd',
                                          fontSize: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Action Buttons (animated slide + fade) ──
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              _buildActionButton(
                                label: 'Add Semester',
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .pushNamed('/add-semester');
                                  _loadData();
                                },
                              ),
                              const SizedBox(height: 25),
                              _buildActionButton(
                                label: 'Show Semesters',
                                onPressed: () async {
                                  await Navigator.of(context)
                                      .pushNamed('/semesters');
                                  _loadData();
                                },
                              ),
                              const SizedBox(height: 25),
                              _buildActionButton(
                                label: 'Target',
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    '/target',
                                    arguments: {
                                      'cgpa': _cgpa?.cgpa ?? 0.0,
                                      'credits':
                                          (_cgpa?.totalCredits ?? 0).toDouble(),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'BauhausStd',
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}
