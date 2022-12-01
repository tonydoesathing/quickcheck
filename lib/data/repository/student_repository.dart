import '../model/student.dart';

/// Abstract definition of a repository for [Student]s
/// Has a subscribable Stream to listen for changes to the list
abstract class StudentRepository {
  /// Returns a list of Students whenever they're changed
  Stream<List<Student>> get students;

  /// Disposes of the StreamController
  void dispose();

  /// Returns a list of Students
  Future<List<Student>> getStudents();

  /// Returns a student from an ID
  Future<Student> getStudent(int id);

  /// Tries to add student to repository and returns whether or not it was successful
  Future<bool> addStudent(Student student);
}
