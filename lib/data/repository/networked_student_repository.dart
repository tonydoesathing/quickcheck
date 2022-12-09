import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:http/http.dart' as http;

class NetworkedStudentRepository extends StudentRepository {
  /// the URL of the API
  final String url;

  /// local cache of students
  List<Student> _students = [];

  /// Stream used to update listeners with changes
  final StreamController<List<Student>> _streamController =
      StreamController<List<Student>>.broadcast();

  /// A networked [Student] repository
  /// Takes the [url] of the endpoint
  NetworkedStudentRepository(this.url);

  @override
  Future<bool> addStudent(Student student) async {
    Response response = await http.post(
      Uri.parse('${url}students/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode != 201) {
      return false;
    }

    // add the newly-created student
    _students.add(Student.fromJson(jsonDecode(response.body)));
    _streamController.add(List<Student>.of(_students));
    return true;
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  Future<Student> getStudent(int id) async {
    Response response = await http.get(Uri.parse('${url}students/$id'));
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json student
      return Student.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw StudentNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '${url}students/$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Student>> getStudents() async {
    Response response = await http.get(Uri.parse('${url}students/'));
    if (response.statusCode == 200 && response.body != "400") {
      // should be a list of json students
      Iterable l = jsonDecode(response.body);
      // make json list into Student list
      _students = List<Student>.from(l.map((json) => Student.fromJson(json)));
      _streamController.add(List<Student>.of(_students));
      return List<Student>.of(_students);
    }
    throw ConnectionFailedException(
        url: '${url}students/', statuscode: response.statusCode);
  }

  @override
  Stream<List<Student>> get students => _streamController.stream;
}

/// An exception for not being able to connect to an endpoint
class ConnectionFailedException implements Exception {
  /// statuscode of the response
  final int? statuscode;

  /// url of the endpoint
  final String? url;

  /// Unable to connect to an endpoint
  ConnectionFailedException({this.url, this.statuscode});

  @override
  String toString() {
    return "Unable to connect: ${url ?? ""} ${statuscode ?? ""}";
  }
}