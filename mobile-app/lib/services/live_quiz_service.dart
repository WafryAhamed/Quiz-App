import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../core/config/app_config.dart';

class LiveQuizService {
  StompClient? _stompClient;

  Future<Map<String, dynamic>> createSession({
    required String token,
    required String lecturerId,
    required String pdfId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/live/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'lecturerId': lecturerId, 'pdfId': pdfId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_parseError(response.body));
  }

  Future<Map<String, dynamic>> joinSession({
    required String token,
    required String code,
    required String userId,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/live/join'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code, 'userId': userId, 'name': name}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_parseError(response.body));
  }

  Future<void> startSession({
    required String token,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/live/start/$code'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response.body));
    }
  }

  Future<List<dynamic>> submitAnswer({
    required String token,
    required String code,
    required String userId,
    required String questionId,
    required String answer,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/live/answer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'code': code,
        'userId': userId,
        'questionId': questionId,
        'answer': answer,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(_parseError(response.body));
  }

  void connectToSession({
    required String code,
    required void Function(Map<String, dynamic>) onQuestion,
    required void Function(List<dynamic>) onLeaderboard,
    required void Function(List<dynamic>) onParticipants,
    void Function(String)? onError,
  }) {
    disconnect();

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: AppConfig.wsBaseUrl,
        onConnect: (frame) {
          _stompClient?.subscribe(
            destination: '/topic/live/$code/question',
            callback: (message) {
              final body = message.body;
              if (body == null) return;
              onQuestion(jsonDecode(body) as Map<String, dynamic>);
            },
          );

          _stompClient?.subscribe(
            destination: '/topic/live/$code/leaderboard',
            callback: (message) {
              final body = message.body;
              if (body == null) return;
              onLeaderboard(jsonDecode(body) as List<dynamic>);
            },
          );

          _stompClient?.subscribe(
            destination: '/topic/live/$code/participants',
            callback: (message) {
              final body = message.body;
              if (body == null) return;
              onParticipants(jsonDecode(body) as List<dynamic>);
            },
          );
        },
        onWebSocketError: (dynamic error) {
          onError?.call('WebSocket error: $error');
        },
        onStompError: (frame) {
          onError?.call('STOMP error: ${frame.body}');
        },
      ),
    );

    _stompClient?.activate();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
  }

  String _parseError(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['message']?.toString() ?? 'Live quiz request failed';
    } catch (_) {
      return 'Live quiz request failed';
    }
  }
}
