import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';

class PdfService {
  Future<Map<String, dynamic>> uploadPdf({
    required String token,
    required String filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.apiBaseUrl}/pdf/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_parseError(response.body));
  }

  String _parseError(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      return map['message']?.toString() ?? 'PDF upload failed';
    } catch (_) {
      return 'PDF upload failed';
    }
  }
}
