import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/semesters/add_semester_screen.dart';
import 'screens/semesters/edit_semester_screen.dart';
import 'screens/semesters/semester_details_screen.dart';
import 'screens/semesters/semester_list_screen.dart';
import 'screens/target/target_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GpaCalculatorApp());
}

class GpaCalculatorApp extends StatelessWidget {
  const GpaCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPA Calculator',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        fontFamily: 'BauhausStd',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _buildSlideRoute(const LoginScreen(), settings);

      case '/register':
        return _buildSlideRoute(const RegisterScreen(), settings);

      case '/home':
        return _buildFadeRoute(const HomeScreen(), settings);

      case '/semesters':
        return _buildSlideRoute(const SemesterListScreen(), settings);

      case '/semester-details':
        final id = settings.arguments as int;
        return _buildSlideRoute(
          SemesterDetailsScreen(semesterId: id),
          settings,
        );

      case '/add-semester':
        return _buildSlideUpRoute(const AddSemesterScreen(), settings);

      case '/edit-semester':
        final id = settings.arguments as int;
        return _buildSlideRoute(
          EditSemesterScreen(semesterId: id),
          settings,
        );

      case '/target':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildSlideRoute(
          TargetScreen(
            cgpa: args['cgpa'] as double,
            credits: args['credits'] as double,
          ),
          settings,
        );

      default:
        return _buildFadeRoute(const LoginScreen(), settings);
    }
  }

  /// Slide from right (standard navigation).
  PageRouteBuilder _buildSlideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  /// Slide up from bottom (for modals like Add Semester).
  PageRouteBuilder _buildSlideUpRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fade = Tween<double>(begin: 0.5, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }

  /// Fade in (for home after auth).
  PageRouteBuilder _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Decides whether to show the login screen or the home screen
/// based on the presence of a stored access token.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with SingleTickerProviderStateMixin {
  final _tokenStorage = TokenStorage();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    // Show the splash for at least 1.5s
    await Future.delayed(const Duration(milliseconds: 1500));
    final hasToken = await _tokenStorage.hasTokens();
    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the cover splash while checking tokens.
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cover.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Container(
                  color: Colors.white.withValues(alpha: 0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
