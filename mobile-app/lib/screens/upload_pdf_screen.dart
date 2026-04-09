import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/storage/session_storage.dart';
import '../services/pdf_service.dart';
import '../widgets/index.dart';
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
      body: GradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
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
                          'Upload PDF 📄',
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
                          'Create quizzes from your lecture notes',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    // File Selection Card
                    GlassCard(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Lecture Notes PDF',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: const Color(0xFF0F3D3E),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF6EDC8C).withOpacity(0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFF6EDC8C).withOpacity(0.05),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  color:
                                      const Color(0xFF6EDC8C).withOpacity(0.6),
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pdfName ?? 'No file selected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: pdfName == null
                                              ? Colors.grey.shade500
                                              : const Color(0xFF0F3D3E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pdfName == null
                                            ? 'Click browse to select'
                                            : 'Ready to upload',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: 'Browse Files',
                                  icon: Icons.attach_file,
                                  onPressed: _pickFile,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  label: _isLoading ? 'Uploading...' : 'Upload',
                                  icon: Icons.upload_file,
                                  isLoading: _isLoading,
                                  onPressed: _isLoading ? null : _uploadPdf,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Result Card
                    if (_uploadResult != null) ...[
                      GlassCard(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFF6EDC8C),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Upload Successful! ✨',
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
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF6EDC8C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: Color(0xFF6EDC8C),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'PDF ID: ${_uploadResult!['pdfId']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6EDC8C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.contact_mail_outlined,
                                        size: 18,
                                        color: Color(0xFF6EDC8C),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Questions: ${_uploadResult!['generatedQuestionCount']} generated',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6EDC8C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: 'Start Quiz',
                              icon: Icons.play_circle_outline,
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
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
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
