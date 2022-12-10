import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';

import 'networked_student_repository.dart';

/// An implementation of the [AssessmentRepository] making use of a networked datastore.
class NetworkedAssessmentRepository extends AssessmentRepository {
  /// Stream used to update listeners with changes
  final StreamController<List<Assessment>> _streamController =
      StreamController<List<Assessment>>.broadcast();

  final String url;

  /// The cache for assessments
  List<Assessment> _assessments = [];

  /// A networked [Assessment] repository
  /// Takes the [url] of the endpoint
  NetworkedAssessmentRepository(this.url);

  @override

  /// Add assessment to _assessments list.
  Future<bool> addAssessment(Assessment assessment) async {
    Response response = await http.post(
      Uri.parse('${url}assessments/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(assessment.toJson()),
    );
    if (response.statusCode != 201) {
      return false;
    }

    // add the newly-created assessment
    // as a workaround for the addAssessment API request not returning a full assessment
    // (no objects), I'm just copying over the ID into the O.G. assessment
    // just delete workaround and uncomment normal code
    // starting workaround
    _assessments.add(assessment.copyWith(id: jsonDecode(response.body)['id']));
    // normal code:
    // _assessments.add(Assessment.fromJson(jsonDecode(response.body)));
    _streamController.add(List<Assessment>.of(_assessments));
    return true;
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override

  /// Get assessment by ID.
  Future<Assessment> getAssessment(int id) async {
    Response response = await http.get(Uri.parse('${url}assessments/$id'));
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json assessment
      return Assessment.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw AssessmentNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '${url}assessments/$id', statuscode: response.statusCode);
    }
  }

  @override

  /// Get list of assessments
  Future<List<Assessment>> getAssessments() async {
    Response response = await http.get(Uri.parse('${url}assessments/'));
    if (response.statusCode == 200 && response.body != "400") {
      // should be a list of json groups
      Iterable l = jsonDecode(response.body);
      // make json list into Assessment list
      _assessments =
          List<Assessment>.from(l.map((json) => Assessment.fromJson(json)));
      // ship it down the stream
      _streamController.add(List<Assessment>.of(_assessments));
      return List<Assessment>.of(_assessments);
    }
    throw ConnectionFailedException(
        url: '${url}groups/', statuscode: response.statusCode);
  }

  @override
  Stream<List<Assessment>> get assessments {
    return _streamController.stream;
  }
}
