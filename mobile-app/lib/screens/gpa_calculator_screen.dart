import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._courses.asMap().entries.map((entry) {
            final index = entry.key;
            final course = entry.value;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: course.courseName,
                      decoration: InputDecoration(
                        labelText: 'Course ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: course.credits,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
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
                              setState(() => course.grade = value ?? 'A');
                            },
                            decoration: const InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCourse,
            icon: const Icon(Icons.add),
            label: const Text('Add Course'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _calculateGpa,
            child: const Text('Calculate GPA'),
          ),
          if (_gpa != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Estimated GPA: ${_gpa!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
