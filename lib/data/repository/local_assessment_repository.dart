import 'dart:async';

import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';

class AssessmentNotFoundException implements Exception {
  int id;

  AssessmentNotFoundException({required this.id}) {}

  @override
  String toString() {
    return "No assessment found with ID $id";
  }
}

class LocalAssessmentRepository extends AssessmentRepository {
  final StreamController<List<Assessment>> _streamController =
      StreamController<List<Assessment>>.broadcast();
  final List<Assessment> _assessments = [];

  @override
  // Add assessment to _assessments list.
  Future<bool> addAssessment(Assessment assessment) async {
    try {
      Assessment newAssessment =
          assessment.copyWith(id: assessment.id ?? _assessments.length + 1);
      _assessments.add(newAssessment);
      _streamController.add(List<Assessment>.of(_assessments));
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
  // Get assessment by ID.
  Future<Assessment> getAssessment(int id) async {
    for (Assessment assessment in _assessments) {
      if (assessment.id == id) {
        return assessment;
      }
    }
    throw AssessmentNotFoundException(id: id);
  }

  @override
  // Get list of assessments
  Future<List<Assessment>> getAssessments() async {
    _streamController.add(List<Assessment>.of(_assessments));
    return List<Assessment>.of(_assessments);
  }

  @override
  Stream<List<Assessment>> get assessments {
    return _streamController.stream;
  }
}
