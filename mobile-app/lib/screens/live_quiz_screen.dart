import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../services/live_quiz_service.dart';
import '../widgets/index.dart';

class LiveQuizScreen extends StatefulWidget {
  const LiveQuizScreen({super.key});

  static const routeName = '/live';

  @override
  State<LiveQuizScreen> createState() => _LiveQuizScreenState();
}

class _LiveQuizScreenState extends State<LiveQuizScreen> {
  final _liveQuizService = LiveQuizService();
  final _codeController = TextEditingController();
  final _pdfIdController = TextEditingController();

  String _sessionCode = '';
  String _role = 'student';
  String _token = '';
  String _userId = '';
  String _name = '';

  Map<String, dynamic>? _activeQuestion;
  List<dynamic> _leaderboard = [];
  List<dynamic> _participants = [];
  String? _selectedAnswer;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await SessionStorage.getToken();
    final userId = await SessionStorage.getUserId();
    final name = await SessionStorage.getName();
    final role = await SessionStorage.getRole();

    if (!mounted) return;

    setState(() {
      _token = token;
      _userId = userId;
      _name = name;
      _role = role;
    });
  }

  Future<void> _createSession() async {
    if (_pdfIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter PDF ID to create live quiz')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await _liveQuizService.createSession(
        token: _token,
        lecturerId: _userId,
        pdfId: _pdfIdController.text.trim(),
      );

      final code = response['code'] as String;
      _codeController.text = code;
      setState(() => _sessionCode = code);
      await _joinSession();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _joinSession() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter session code first')));
      return;
    }

    setState(() => _loading = true);
    try {
      await _liveQuizService.joinSession(
        token: _token,
        code: code,
        userId: _userId,
        name: _name,
      );

      _liveQuizService.connectToSession(
        code: code,
        onQuestion: (question) {
          if (!mounted) return;
          setState(() {
            _activeQuestion = question;
            _selectedAnswer = null;
          });
        },
        onLeaderboard: (leaderboard) {
          if (!mounted) return;
          setState(() => _leaderboard = leaderboard);
        },
        onParticipants: (participants) {
          if (!mounted) return;
          setState(() => _participants = participants);
        },
        onError: (message) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );

      if (!mounted) return;
      setState(() => _sessionCode = code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Joined live session $code')));
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startSession() async {
    if (_sessionCode.isEmpty) return;

    try {
      await _liveQuizService.startSession(token: _token, code: _sessionCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Live quiz $_sessionCode started')),
      );
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _submitAnswer() async {
    if (_activeQuestion == null ||
        _selectedAnswer == null ||
        _sessionCode.isEmpty) {
      return;
    }

    try {
      final updatedLeaderboard = await _liveQuizService.submitAnswer(
        token: _token,
        code: _sessionCode,
        userId: _userId,
        questionId: _activeQuestion!['id'] as String,
        answer: _selectedAnswer!,
      );
      if (!mounted) return;
      setState(() => _leaderboard = updatedLeaderboard);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Answer submitted')));
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  @override
  void dispose() {
    _liveQuizService.disconnect();
    _codeController.dispose();
    _pdfIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options =
        (_activeQuestion?['options'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
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
                        const SizedBox(height: 8),
                        Text(
                          'Live Quiz 📡',
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
                          'Real-time quiz sessions',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Lecturer Controls
                    if (_role == 'lecturer') ...[
                      GlassCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lecturer Controls 🎓',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: const Color(0xFF0F3D3E),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _pdfIdController,
                              label: 'PDF ID',
                              prefixIcon: Icons.note_outlined,
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Create Live Session',
                              isLoading: _loading,
                              onPressed: _loading ? null : _createSession,
                            ),
                            if (_sessionCode.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SecondaryButton(
                                label: 'Start Session $_sessionCode',
                                icon: Icons.play_circle_outline,
                                onPressed: _startSession,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Join Session
                    GlassCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join Session',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF0F3D3E),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _codeController,
                            label: 'Session Code',
                            hint: 'e.g., ABC123',
                            prefixIcon: Icons.vpn_key_outlined,
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: 'Join Live Quiz',
                            isLoading: _loading,
                            onPressed: _loading ? null : _joinSession,
                          ),
                        ],
                      ),
                    ),

                    // Question & Options
                    if (_activeQuestion != null) ...[
                      GlassCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Question',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activeQuestion!['question'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF0F3D3E),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...options.map((option) {
                              final isSelected = _selectedAnswer == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedAnswer = option);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF6EDC8C)
                                          : Colors.white.withOpacity(0.3),
                                      width: isSelected ? 2 : 1.5,
                                    ),
                                    color: isSelected
                                        ? const Color(0xFF6EDC8C).withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF6EDC8C)
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Color(0xFF6EDC8C),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? const Color(0xFF0F3D3E)
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Submit Answer',
                              onPressed:
                                  _selectedAnswer == null ? null : _submitAnswer,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      GlassCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Waiting for lecturer...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Leaderboard
                    GlassCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Color(0xFF6EDC8C),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Leaderboard',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF0F3D3E),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_leaderboard.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'No scores yet',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._leaderboard.map((item) {
                              final row = item as Map<String, dynamic>;
                              final position =
                                  _leaderboard.indexOf(item) + 1;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: position == 1
                                      ? const Color(0xFF6EDC8C).withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text(
                                        '#$position',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      position == 1
                                          ? Icons.star
                                          : Icons.person_outline,
                                      size: 16,
                                      color: position == 1
                                          ? const Color(0xFF6EDC8C)
                                          : Colors.grey.shade400,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        row['name']?.toString() ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: position == 1
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: position == 1
                                              ? const Color(0xFF0F3D3E)
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB7E36D),
                                            Color(0xFF6EDC8C),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${row['score']} pts',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F3D3E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    // Participants
                    GlassCard(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                color: Color(0xFF6EDC8C),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Participants (${_participants.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF0F3D3E),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
