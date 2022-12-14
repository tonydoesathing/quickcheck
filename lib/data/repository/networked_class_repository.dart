import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/class_repository.dart';
import 'package:quickcheck/data/repository/networked_student_repository.dart';

/// An implementation of the [ClassRepository] making use of a networked datastore.
class NetworkedClassRepository implements ClassRepository {
  /// Stream used to update listeners with changes
  final StreamController<List<Class>> _streamController =
      StreamController<List<Class>>.broadcast();

  /// the url of the endpoint
  final String url;

  /// the cache of the classes
  List<Class> _classesCache = [];

  /// A networked [Class] repository
  /// Takes the [url] of the endpoint
  NetworkedClassRepository(this.url);

  @override
  Future<Class?> addClass(Class clss) async {
    Response response = await http.post(
      Uri.parse('${url}classes/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(clss.toJson()),
    );
    if (response.statusCode != 201) {
      return null;
    }
    final Class newClass = Class.fromJson(jsonDecode(response.body));
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
    Response response = await http.get(Uri.parse('${url}classes/$id'));
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json assessment
      return Class.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw ClassNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '${url}classes/$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Class>> getClasses() async {
    Response response = await http.get(Uri.parse('${url}classes/'));
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
          url: '${url}classes/', statuscode: response.statusCode);
    }
  }
}
