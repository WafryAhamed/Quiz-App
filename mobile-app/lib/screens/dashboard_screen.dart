import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../widgets/index.dart';
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
      body: GradientBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, String>>(
            future: _loadProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Ayubowan 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: const Color(0xFF0F3D3E),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile['name'] ?? 'User',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFF0F3D3E),
                        ),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),

                  // Profile Card
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB7E36D),
                                    Color(0xFF6EDC8C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF0F3D3E),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['name'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F3D3E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Role: ${profile['role']?.capitalize() ?? 'Student'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Menu Items
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SubjectCard(
                          title: 'Upload PDF & Generate Quiz',
                          subtitle: 'Create quizzes from your notes',
                          icon: Icons.picture_as_pdf,
                          onTap: () => Navigator.pushNamed(
                            context,
                            UploadPdfScreen.routeName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SubjectCard(
                          title: 'Flashcards',
                          subtitle: 'Practice with flashcards',
                          icon: Icons.style,
                          onTap: () => Navigator.pushNamed(
                            context,
                            FlashcardsScreen.routeName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SubjectCard(
                          title: 'GPA Calculator',
                          subtitle: 'Calculate your GPA',
                          icon: Icons.calculate,
                          onTap: () => Navigator.pushNamed(
                            context,
                            GpaCalculatorScreen.routeName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SubjectCard(
                          title: 'Live Quiz Join / Create',
                          subtitle: 'Real-time quiz sessions',
                          icon: Icons.wifi_tethering,
                          onTap: () => Navigator.pushNamed(
                            context,
                            LiveQuizScreen.routeName,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
