import 'dart:async';

import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/student_repository.dart';

class StudentNotFoundException implements Exception {
  int id;

  StudentNotFoundException({required this.id}) {}

  @override
  String toString() {
    return "No student found with ID $id";
  }
}

class LocalStudentRepository extends StudentRepository {
  final StreamController<List<Student>> _streamController =
      StreamController<List<Student>>.broadcast();
  final List<Student> _students = [];

  @override
  // Add student to _students list.
  Future<bool> addStudent(Student student) async {
    try {
      Student newStudent =
          student.copyWith(id: student.id ?? _students.length + 1);
      _students.add(newStudent);
      _streamController.add(List<Student>.of(_students));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  // Get student by ID.
  Future<Student> getStudent(int id) async {
    for (Student student in _students) {
      if (student.id == id) {
        return student;
      }
    }
    throw StudentNotFoundException(id: id);
  }

  @override
  // Get list of students
  Future<List<Student>> getStudents() async {
    _streamController.add(List<Student>.of(_students));
    return List<Student>.of(_students);
  }

  @override
  Stream<List<Student>> get students {
    return _streamController.stream;
  }
}
