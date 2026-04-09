import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../services/pdf_service.dart';
import 'quiz_screen.dart';

class UploadPdfScreen extends StatefulWidget {
  const UploadPdfScreen({super.key});

  static const routeName = '/upload';

  @override
  State<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends State<UploadPdfScreen> {
  final _pdfService = PdfService();
  String? _selectedPath;
  Map<String, dynamic>? _uploadResult;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPath = result.files.single.path;
        _uploadResult = null;
      });
    }
  }

  Future<void> _uploadPdf() async {
    final path = _selectedPath;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await SessionStorage.getToken();
      final response = await _pdfService.uploadPdf(
        token: token,
        filePath: path,
      );
      if (!mounted) return;
      setState(() => _uploadResult = response);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfName = _selectedPath == null
        ? null
        : File(_selectedPath!).uri.pathSegments.last;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Lecture Notes PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(pdfName ?? 'No file selected'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Choose PDF'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _uploadPdf,
                            icon: const Icon(Icons.upload_file),
                            label: _isLoading
                                ? const Text('Uploading...')
                                : const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_uploadResult != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PDF ID: ${_uploadResult!['pdfId']}'),
                      const SizedBox(height: 6),
                      Text(
                        'Generated Questions: ${_uploadResult!['generatedQuestionCount']}',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                pdfId: _uploadResult!['pdfId'] as String,
                              ),
                            ),
                          );
                        },
                        child: const Text('Start Quiz'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
