import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../models/question_model.dart';
import '../services/quiz_service.dart';

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
          title: const Text('Quiz Result'),
          content: Text(
            'Correct: ${result['correctAnswers']} / ${result['totalQuestions']}\n'
            'Score: ${(result['scorePercentage'] as num).toStringAsFixed(2)}%',
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions available for this PDF yet.'),
        ),
      );
    }

    final question = _questions[_index];
    final selected = _answers[question.id];
    final isLast = _index == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz ${_index + 1}/${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Difficulty: ${question.difficulty.toUpperCase()}'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, i) {
                  final option = question.options[i];
                  final isSelected = selected == option;
                  return Card(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: ListTile(
                      onTap: () {
                        setState(() => _answers[question.id] = option);
                      },
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () {
                        if (!isLast) {
                          setState(() => _index += 1);
                        } else {
                          _submitQuiz();
                        }
                      },
                child: Text(isLast ? 'Submit Quiz' : 'Next Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
