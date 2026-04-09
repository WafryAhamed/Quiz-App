import 'package:flutter/material.dart';

import '../widgets/index.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  static const routeName = '/gpa';

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _CourseInput {
  _CourseInput({
    required this.courseName,
    required this.credits,
    this.grade = 'A',
  });

  final TextEditingController courseName;
  final TextEditingController credits;
  String grade;
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<_CourseInput> _courses = [
    _CourseInput(
      courseName: TextEditingController(text: 'CS2102 - Data Structures'),
      credits: TextEditingController(text: '3'),
    ),
    _CourseInput(
      courseName: TextEditingController(text: 'IS2201 - Database Systems'),
      credits: TextEditingController(text: '3'),
      grade: 'B+',
    ),
    _CourseInput(
      courseName: TextEditingController(text: 'SE2304 - Software Engineering'),
      credits: TextEditingController(text: '2'),
      grade: 'A-',
    ),
  ];

  final Map<String, double> _points = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D': 1.0,
    'E': 0.0,
  };

  double? _gpa;

  @override
  void dispose() {
    for (final course in _courses) {
      course.courseName.dispose();
      course.credits.dispose();
    }
    super.dispose();
  }

  void _addCourse() {
    setState(() {
      _courses.add(
        _CourseInput(
          courseName: TextEditingController(text: 'New Module'),
          credits: TextEditingController(text: '3'),
        ),
      );
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses[index].courseName.dispose();
      _courses[index].credits.dispose();
      _courses.removeAt(index);
      _gpa = null;
    });
  }

  void _calculateGpa() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (final course in _courses) {
      final credits = double.tryParse(course.credits.text.trim()) ?? 0;
      final gradePoint = _points[course.grade] ?? 0;
      totalCredits += credits;
      totalPoints += credits * gradePoint;
    }

    setState(() {
      _gpa = totalCredits == 0 ? 0 : totalPoints / totalCredits;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          'GPA Calculator 📊',
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
                          'Calculate your academic performance',
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
                    // GPA Result
                    if (_gpa != null) ...[
                      GlassCard(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'Your GPA',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFB7E36D),
                                    Color(0xFF6EDC8C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  _gpa!.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F3D3E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getGradeLabel(_gpa!),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: _getGradeColor(_gpa!),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Add Course Button
                    SecondaryButton(
                      label: 'Add Course',
                      icon: Icons.add,
                      onPressed: _addCourse,
                    ),
                    const SizedBox(height: 16),

                    // Courses
                    ..._courses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final course = entry.value;

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Course ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6EDC8C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_courses.length > 1)
                                  GestureDetector(
                                    onTap: () => _removeCourse(index),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Color(0xFF6EDC8C),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: course.courseName,
                              label: 'Course Name',
                              hint: 'e.g., CS2102',
                              prefixIcon: Icons.library_books_outlined,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CustomTextField(
                                    controller: course.credits,
                                    label: 'Credits',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.numbers,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: course.grade,
                                      items: _points.keys
                                          .map(
                                            (grade) => DropdownMenuItem(
                                              value: grade,
                                              child: Text(grade),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        setState(
                                            () => course.grade = value ?? 'A');
                                        _gpa = null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Grade',
                                        prefixIcon: const Icon(Icons.grade),
                                        filled: true,
                                        fillColor:
                                            Colors.white.withValues(alpha: 0.8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color:
                                                Colors.white.withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color:
                                                Colors.white.withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF6EDC8C),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Calculate Button
                    PrimaryButton(
                      label: 'Calculate GPA',
                      icon: Icons.calculate,
                      onPressed: _calculateGpa,
                    ),
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

  String _getGradeLabel(double gpa) {
    if (gpa >= 3.8) return 'Excellent';
    if (gpa >= 3.5) return 'Very Good';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.5) return 'Satisfactory';
    return 'Needs Improvement';
  }

  Color _getGradeColor(double gpa) {
    if (gpa >= 3.8) return const Color(0xFF6EDC8C);
    if (gpa >= 3.5) return const Color(0xFF9FE870);
    if (gpa >= 3.0) return const Color(0xFFB7E36D);
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red.shade400;
  }
}
