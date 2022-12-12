import 'dart:async';

import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/student_repository.dart';

/// The LocalStudentRepository is an implementation of the [StudentRepository] making use of an in-memory datastore.
class LocalStudentRepository extends StudentRepository {
  /// Stream used to update listeners with changes
  final StreamController<List<Student>> _streamController =
      StreamController<List<Student>>.broadcast();

  /// The datastore for students
  final List<Student> _students = [];

  @override

  /// Add student to _students list.
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

  /// Get student by ID.
  Future<Student> getStudent(int id) async {
    for (Student student in _students) {
      if (student.id == id) {
        return student;
      }
    }
    throw StudentNotFoundException(id: id);
  }

  @override

  /// Get list of students
  Future<List<Student>> getStudents(int classId) async {
    return List<Student>.of(
        _students.where((student) => student.classId == classId));
  }

  @override
  Stream<List<Student>> get students {
    return _streamController.stream;
  }
}
