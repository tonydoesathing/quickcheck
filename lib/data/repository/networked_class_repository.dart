import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/class_repository.dart';
import 'package:quickcheck/data/repository/networked_student_repository.dart';

/// An implementation of the [ClassRepository] making use of a networked datastore.
class NetworkedClassRepository implements ClassRepository {
  /// endpoint
  static const String endpoint = "api/classes/";

  /// Stream used to update listeners with changes
  final StreamController<List<Class>> _streamController =
      StreamController<List<Class>>.broadcast();

  /// the url of the endpoint
  final AuthenticationRepository authenticationRepository;

  /// the cache of the classes
  List<Class> _classesCache = [];

  /// A networked [Class] repository
  /// Takes the [url] of the endpoint
  NetworkedClassRepository(this.authenticationRepository);

  @override
  Future<Class?> addClass(Class clss) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.post(
      Uri.parse(
        '$url$endpoint',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${await authenticationRepository.getToken()}'
      },
      body: jsonEncode(clss.toJson()),
    );
    if (response.statusCode != 201) {
      return null;
    }
    final Class newClass = Class.fromJson(jsonDecode(response.body));
    // log analytics event
    await FirebaseAnalytics.instance.logEvent(name: "add_class", parameters: {
      "name_length": newClass.name.length,
    });
    _classesCache.add(newClass);
    _streamController.add(_classesCache.toList());
    return newClass;
  }

  @override
  Stream<List<Class>> get classes => _streamController.stream;

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  Future<Class> getClass(int id) async {
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
      return Class.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw ClassNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Class>> getClasses() async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.get(Uri.parse('$url$endpoint'),
        headers: <String, String>{
          'Authorization': 'Token ${await authenticationRepository.getToken()}'
        });
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json assessment
      final List<Class> classes = (jsonDecode(response.body) as List)
          .map((element) => Class.fromJson(element))
          .toList();
      _classesCache = classes;
      _streamController.add(classes);
      return classes;
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint', statuscode: response.statusCode);
    }
  }
}
