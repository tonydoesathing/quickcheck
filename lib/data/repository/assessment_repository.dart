import 'package:quickcheck/data/model/assessment.dart';

/// Abstract definition of a repository for [Assessment]s
/// Has a subscribable Stream to listen for changes to the list
abstract class AssessmentRepository {
  /// Returns a list of Assessments whenever they're changed
  Stream<List<Assessment>> get assessments;

  /// Disposes of the StreamController
  void dispose();

  /// Returns a list of Assessments
  Future<List<Assessment>> getAssessments(int classId);

  /// Returns a Assessment from an ID
  Future<Assessment> getAssessment(int id);

  /// Tries to add assessment to repository and returns the new assessument if successful
  Future<Assessment?> addAssessment(Assessment assessment);

  /// Tries to edit an assessment and returns edited assessment if successful
  /// Throws [AssessmentNotFoundException] if unable to find the assessment
  Future<Assessment?> editAssessment(Assessment assessment);
}

/// [Assessment] with id of [id] could not be found in datastore
class AssessmentNotFoundException implements Exception {
  int id;

  /// Exception: [Assessment] with id of [id] could not be found in datastore
  AssessmentNotFoundException({required this.id}) {}

  @override
  String toString() {
    return "No assessment found with ID $id";
  }
}
