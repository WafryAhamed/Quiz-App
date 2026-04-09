import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/storage/session_storage.dart';
import 'screens/dashboard_screen.dart';
import 'screens/flashcards_screen.dart';
import 'screens/gpa_calculator_screen.dart';
import 'screens/live_quiz_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/upload_pdf_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const QuizLearningApp());
}

class QuizLearningApp extends StatelessWidget {
  const QuizLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6EDC8C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FDFB),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.75),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          labelStyle: const TextStyle(
            color: Color(0xFF6EDC8C),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: Color(0xFF6EDC8C),
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EDC8C),
            foregroundColor: const Color(0xFF0F3D3E),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
        ),
      ),
      home: const _StartupGate(),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
        UploadPdfScreen.routeName: (_) => const UploadPdfScreen(),
        FlashcardsScreen.routeName: (_) => const FlashcardsScreen(),
        GpaCalculatorScreen.routeName: (_) => const GpaCalculatorScreen(),
        LiveQuizScreen.routeName: (_) => const LiveQuizScreen(),
      },
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<bool> _hasToken() async {
    final token = await SessionStorage.getToken();
    return token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data! ? const DashboardScreen() : const LoginScreen();
      },
    );
  }
}
