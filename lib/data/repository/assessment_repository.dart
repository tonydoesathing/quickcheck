import 'package:quickcheck/data/model/assessment.dart';

/// Abstract definition of a repository for [Assessment]s
/// Has a subscribable Stream to listen for changes to the list
abstract class AssessmentRepository {
  /// Returns a list of Assessments whenever they're changed
  Stream<List<Assessment>> get assessments;

  /// Disposes of the StreamController
  void dispose();

  /// Returns a list of Assessments
  Future<List<Assessment>> getAssessments();

  /// Returns a Assessment from an ID
  Future<Assessment> getAssessment(int id);

  /// Tries to add assessment to repository and returns whether or not it was successful
  Future<bool> addAssessment(Assessment assessment);
}
