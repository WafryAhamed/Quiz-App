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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
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
