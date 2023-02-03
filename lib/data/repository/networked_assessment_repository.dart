import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';

import 'networked_student_repository.dart';

/// An implementation of the [AssessmentRepository] making use of a networked datastore.
class NetworkedAssessmentRepository extends AssessmentRepository {
  /// endpoint
  static const String endpoint = "api/assessments/";

  /// Stream used to update listeners with changes
  final StreamController<List<Assessment>> _streamController =
      StreamController<List<Assessment>>.broadcast();

  /// the auth repo
  final AuthenticationRepository authenticationRepository;

  /// The cache for assessments
  List<Assessment> _assessments = [];

  /// A networked [Assessment] repository
  /// Takes the [url] of the endpoint
  NetworkedAssessmentRepository(this.authenticationRepository);

  @override

  /// Add assessment to _assessments list.
  Future<Assessment?> addAssessment(Assessment assessment) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.post(
      Uri.parse('$url$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${await authenticationRepository.getToken()}'
      },
      body: jsonEncode(assessment.toJson()),
    );
    if (response.statusCode != 201) {
      return null;
    }
    // add the newly-created assessment
    final Assessment newAssessment =
        assessment.copyWith(id: jsonDecode(response.body)['id']);

    // log analytics event
    await FirebaseAnalytics.instance
        .logEvent(name: "add_assessment", parameters: {
      "number_of_scores": assessment.scoreMap.length,
      "name_length": assessment.name.length
    });
    // add the assessment
    _assessments.add(newAssessment);
    _streamController.add(List<Assessment>.of(_assessments));
    return newAssessment;
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override

  /// Get assessment by ID.
  Future<Assessment> getAssessment(int id) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.get(Uri.parse('$url$endpoint$id'),
        headers: <String, String>{
          'Authorization': 'Token ${await authenticationRepository.getToken()}'
        });
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json assessment
      return Assessment.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw AssessmentNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint$id', statuscode: response.statusCode);
    }
  }

  @override

  /// Get list of assessments
  Future<List<Assessment>> getAssessments(int classId) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.get(
        Uri.parse('$url$endpoint?class_id=$classId'),
        headers: <String, String>{
          'Authorization': 'Token ${await authenticationRepository.getToken()}'
        });
    if (response.statusCode == 200 && response.body != "400") {
      // should be a list of json assessments
      List jsonAssessments = jsonDecode(response.body);

      // make json list into Assessment list
      _assessments = List<Assessment>.from(
          jsonAssessments.map((json) => Assessment.fromJson(json)));
      // ship it down the stream
      _streamController.add(List<Assessment>.of(_assessments));
      return List<Assessment>.of(_assessments);
    }
    throw ConnectionFailedException(
        url: '$url$endpoint?class_id=$classId',
        statuscode: response.statusCode);
  }

  @override
  Stream<List<Assessment>> get assessments {
    return _streamController.stream;
  }

  @override
  Future<Assessment?> editAssessment(Assessment assessment) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.put(
      Uri.parse('$url$endpoint${assessment.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${await authenticationRepository.getToken()}'
      },
      body: jsonEncode(assessment.toJson()),
    );
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json assessment
      // edit local cache
      int index =
          _assessments.indexWhere((element) => element.id == assessment.id);
      if (index == -1) {
        // could not find the assessment id
        throw AssessmentNotFoundException(id: assessment.id ?? -1);
      }
      Assessment oldAssessment = _assessments[index];
      // log analytics event
      await FirebaseAnalytics.instance
          .logEvent(name: "edit_assessment", parameters: {
        "number_of_scores": assessment.scoreMap.length,
        "name_length": assessment.name.length,
        "old_number_of_scores": oldAssessment.scoreMap.length,
        "old_name_length": oldAssessment.name.length,
      });

      // update the assessment
      _assessments[index] = assessment;
      _streamController.add(List.from(_assessments));
      return Assessment.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw AssessmentNotFoundException(id: assessment.id ?? -1);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint${assessment.id}',
          statuscode: response.statusCode);
    }
  }
}
