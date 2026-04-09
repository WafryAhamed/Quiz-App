import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../services/live_quiz_service.dart';

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
      appBar: AppBar(title: const Text('Live Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_role == 'lecturer')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Lecturer Controls',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pdfIdController,
                      decoration: const InputDecoration(
                        labelText: 'PDF ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loading ? null : _createSession,
                      child: const Text('Create Live Session'),
                    ),
                    if (_sessionCode.isNotEmpty)
                      OutlinedButton(
                        onPressed: _startSession,
                        child: Text('Start Session $_sessionCode'),
                      ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Join Session',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Session Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _joinSession,
                    child: const Text('Join Live Quiz'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Participants: ${_participants.length}'),
                  const SizedBox(height: 8),
                  if (_activeQuestion != null) ...[
                    Text(
                      _activeQuestion!['question'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...options.map((option) {
                      final isSelected = _selectedAnswer == option;
                      return Card(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          onTap: () {
                            setState(() => _selectedAnswer = option);
                          },
                          leading: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: Text(option),
                        ),
                      );
                    }),
                    ElevatedButton(
                      onPressed: _selectedAnswer == null ? null : _submitAnswer,
                      child: const Text('Submit Live Answer'),
                    ),
                  ] else
                    const Text(
                      'Waiting for lecturer to start and push questions...',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leaderboard',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (_leaderboard.isEmpty)
                    const Text('No scores yet')
                  else
                    ..._leaderboard.map((item) {
                      final row = item as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.emoji_events),
                        title: Text(row['name']?.toString() ?? '-'),
                        trailing: Text('${row['score']} pts'),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
