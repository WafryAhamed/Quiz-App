import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../models/question_model.dart';
import '../services/quiz_service.dart';
import '../widgets/index.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.pdfId});

  final String pdfId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _quizService = QuizService();

  bool _isLoading = true;
  int _index = 0;
  List<QuestionModel> _questions = [];
  final Map<String, String> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final token = await SessionStorage.getToken();
      final questions = await _quizService.fetchQuestions(
        token: token,
        pdfId: widget.pdfId,
      );

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _submitQuiz() async {
    try {
      final token = await SessionStorage.getToken();
      final result = await _quizService.submitQuiz(
        token: token,
        pdfId: widget.pdfId,
        answers: _answers,
      );

      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Quiz Complete! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB7E36D),
                      Color(0xFF6EDC8C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result['correctAnswers']}/${result['totalQuestions']}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F3D3E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${(result['scorePercentage'] as num).toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F3D3E),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: GradientBackground(
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: GradientBackground(
          child: Center(
            child: Text(
              'No questions available for this PDF yet.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ),
      );
    }

    final question = _questions[_index];
    final selected = _answers[question.id];
    final isLast = _index == _questions.length - 1;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF0F3D3E),
                        size: 20,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Question ${_index + 1}/${_questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F3D3E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_index + 1) / _questions.length,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6EDC8C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40,
                      child: Chip(
                        label: Text(
                          question.difficulty.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0F3D3E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: _getDifficultyColor(
                          question.difficulty,
                        ).withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF0F3D3E),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, i) {
                      final option = question.options[i];
                      final isSelected = selected == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _answers[question.id] = option);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6EDC8C)
                                  : Colors.white.withOpacity(0.3),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            color: isSelected
                                ? const Color(0xFF6EDC8C).withOpacity(0.1)
                                : Colors.white.withOpacity(0.75),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF6EDC8C)
                                          .withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF6EDC8C)
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check,
                                            size: 16,
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
                                      fontSize: 15,
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                PrimaryButton(
                  label: isLast ? 'Submit Quiz' : 'Next Question',
                  onPressed: selected == null
                      ? null
                      : () {
                          if (!isLast) {
                            setState(() => _index += 1);
                          } else {
                            _submitQuiz();
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF6EDC8C);
      case 'medium':
        return const Color(0xFF9FE870);
      case 'hard':
        return const Color(0xFFB7E36D);
      default:
        return Colors.grey;
    }
  }
}
