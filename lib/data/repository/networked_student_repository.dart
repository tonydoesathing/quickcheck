import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:http/http.dart' as http;

class NetworkedStudentRepository extends StudentRepository {
  /// the endppoint
  static const String endpoint = "api/students/";

  /// the auth repo
  final AuthenticationRepository authenticationRepository;

  /// local cache of students
  List<Student> _students = [];

  /// Stream used to update listeners with changes
  final StreamController<List<Student>> _streamController =
      StreamController<List<Student>>.broadcast();

  /// A networked [Student] repository
  /// Takes the [url] of the endpoint
  NetworkedStudentRepository(this.authenticationRepository);

  @override
  Future<Student?> addStudent(Student student) async {
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
      body: jsonEncode(student.toJson()),
    );
    if (response.statusCode != 201) {
      return null;
    }

    // add the newly-created student
    final Student newStudent = Student.fromJson(jsonDecode(response.body));
    _students.add(newStudent);
    _streamController.add(List<Student>.of(_students));
    return newStudent;
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  Future<Student> getStudent(int id) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.get(Uri.parse('$url$endpoint$id'),
        headers: <String, String>{
          'Authorization': 'Token ${await authenticationRepository.getToken()}'
        });
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json student
      return Student.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw StudentNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Student>> getStudents(int classId) async {
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
      // should be a list of json students
      Iterable l = jsonDecode(response.body);
      // make json list into Student list
      _students = List<Student>.from(l.map((json) => Student.fromJson(json)));
      _streamController.add(List<Student>.of(_students));
      return List<Student>.of(_students);
    }
    throw ConnectionFailedException(
        url: '$url$endpoint?class_id=$classId',
        statuscode: response.statusCode);
  }

  @override
  Stream<List<Student>> get students => _streamController.stream;

  @override
  Future<Student?> editStudent(Student student) async {
    Response response =
        await http.put(Uri.parse('${url}students/${student.id}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(student.toJson()));
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json student
      return Student.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw StudentNotFoundException(id: student.id ?? -1);
    } else {
      throw ConnectionFailedException(
          url: '${url}students/${student.id}', statuscode: response.statusCode);
    }
  }
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
