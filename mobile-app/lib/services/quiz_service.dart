import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/question_model.dart';

class QuizService {
  Future<List<QuestionModel>> fetchQuestions({
    required String token,
    required String pdfId,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/quiz/$pdfId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_parseError(response.body));
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String token,
    required String pdfId,
    required Map<String, String> answers,
  }) async {
    final payload = {
      'pdfId': pdfId,
      'answers': answers.entries
          .map((entry) => {'questionId': entry.key, 'answer': entry.value})
          .toList(),
    };

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/quiz/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_parseError(response.body));
  }

  String _parseError(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['message']?.toString() ?? 'Quiz request failed';
    } catch (_) {
      return 'Quiz request failed';
    }
  }
}
