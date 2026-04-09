import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import 'flashcards_screen.dart';
import 'gpa_calculator_screen.dart';
import 'live_quiz_screen.dart';
import 'login_screen.dart';
import 'upload_pdf_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<Map<String, String>> _loadProfile() async {
    final name = await SessionStorage.getName();
    final role = await SessionStorage.getRole();
    return {'name': name, 'role': role};
  }

  Future<void> _logout() async {
    await SessionStorage.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Learning Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Ayubowan, ${profile['name'] ?? ''}!'),
                  subtitle: Text('Role: ${profile['role'] ?? 'student'}'),
                ),
              ),
              const SizedBox(height: 16),
              _menuTile(
                context,
                title: 'Upload PDF & Generate Quiz',
                icon: Icons.picture_as_pdf,
                routeName: UploadPdfScreen.routeName,
              ),
              _menuTile(
                context,
                title: 'Flashcards',
                icon: Icons.style,
                routeName: FlashcardsScreen.routeName,
              ),
              _menuTile(
                context,
                title: 'GPA Calculator',
                icon: Icons.calculate,
                routeName: GpaCalculatorScreen.routeName,
              ),
              _menuTile(
                context,
                title: 'Live Quiz Join / Create',
                icon: Icons.wifi_tethering,
                routeName: LiveQuizScreen.routeName,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }
}
