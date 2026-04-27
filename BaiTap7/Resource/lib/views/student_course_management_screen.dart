import 'package:flutter/material.dart';

class Student {
  Student({required this.id, required this.name});

  final int id;
  final String name;
}

class Course {
  Course({required this.id, required this.name});

  final int id;
  final String name;
}

class Enrollment {
  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
  });

  final int id;
  final int studentId;
  final int courseId;
}

class StudentCourseManagementScreen extends StatefulWidget {
  const StudentCourseManagementScreen({super.key});

  @override
  State<StudentCourseManagementScreen> createState() =>
      _StudentCourseManagementScreenState();
}

class _StudentCourseManagementScreenState
    extends State<StudentCourseManagementScreen> {
  final List<Student> _students = [];
  final List<Course> _courses = [];
  final List<Enrollment> _enrollments = [];

  int _studentIdCounter = 1;
  int _courseIdCounter = 1;
  int _enrollmentIdCounter = 1;

  void _addStudent(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    setState(() {
      _students.add(Student(id: _studentIdCounter++, name: trimmedName));
    });
  }

  void _addCourse(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    setState(() {
      _courses.add(Course(id: _courseIdCounter++, name: trimmedName));
    });
  }

  bool _isStudentEnrolledInCourse(int studentId, int courseId) {
    return _enrollments.any(
      (enrollment) =>
          enrollment.studentId == studentId && enrollment.courseId == courseId,
    );
  }

  void _toggleEnrollment({
    required int studentId,
    required int courseId,
    required bool shouldEnroll,
  }) {
    setState(() {
      final index = _enrollments.indexWhere(
        (enrollment) =>
            enrollment.studentId == studentId &&
            enrollment.courseId == courseId,
      );

      if (shouldEnroll && index == -1) {
        _enrollments.add(
          Enrollment(
            id: _enrollmentIdCounter++,
            studentId: studentId,
            courseId: courseId,
          ),
        );
      }

      if (!shouldEnroll && index != -1) {
        _enrollments.removeAt(index);
      }
    });
  }

  List<Course> _coursesOfStudent(int studentId) {
    final enrolledCourseIds = _enrollments
        .where((enrollment) => enrollment.studentId == studentId)
        .map((enrollment) => enrollment.courseId)
        .toSet();

    return _courses
        .where((course) => enrolledCourseIds.contains(course.id))
        .toList(growable: false);
  }

  Future<void> _showAddDialog({
    required String title,
    required String hintText,
    required void Function(String value) onSubmit,
  }) async {
    var currentValue = '';

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: hintText),
            onChanged: (value) {
              currentValue = value;
            },
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(currentValue);
              },
              child: const Text('Luu'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      onSubmit(result);
    });
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(label: 'Sinh vien', value: _students.length),
            _SummaryItem(label: 'Mon hoc', value: _courses.length),
            _SummaryItem(label: 'Dang ky', value: _enrollments.length),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noDataYet = _students.isEmpty || _courses.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('He thong quan ly dang ky mon hoc - 6451071041'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _showAddDialog(
                        title: 'Them sinh vien',
                        hintText: 'Nhap ten sinh vien',
                        onSubmit: _addStudent,
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Them sinh vien'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _showAddDialog(
                        title: 'Them mon hoc',
                        hintText: 'Nhap ten mon hoc',
                        onSubmit: _addCourse,
                      );
                    },
                    icon: const Icon(Icons.library_add),
                    label: const Text('Them mon hoc'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _students.isEmpty
                  ? const Center(
                      child: Text(
                        'Chua co sinh vien. Hay them sinh vien truoc.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final selectedCourses = _coursesOfStudent(student.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text('${student.name} (ID: ${student.id})'),
                            subtitle: Text(
                              selectedCourses.isEmpty
                                  ? 'Chua dang ky mon nao'
                                  : 'Da dang ky: ${selectedCourses.map((e) => e.name).join(', ')}',
                            ),
                            childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            children: [
                              if (noDataYet)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Can co du sinh vien va mon hoc de dang ky.',
                                  ),
                                )
                              else
                                ..._courses.map(
                                  (course) => CheckboxListTile(
                                    value: _isStudentEnrolledInCourse(
                                      student.id,
                                      course.id,
                                    ),
                                    title: Text(course.name),
                                    subtitle: Text('Course ID: ${course.id}'),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    onChanged: (value) {
                                      _toggleEnrollment(
                                        studentId: student.id,
                                        courseId: course.id,
                                        shouldEnroll: value ?? false,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
