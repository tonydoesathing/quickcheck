import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/authentification_repository.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:http/http.dart' as http;

import 'networked_student_repository.dart';

/// A networked [Group] repository
class NetworkedGroupRepository extends GroupRepository {
  /// endpoint
  static const String endpoint = "api/groups/";

  /// the authenitcation repository
  final AuthenticationRepository authenticationRepository;

  /// local cache of groups
  List<Group> _groups = [];

  /// Stream used to update listeners with changes
  final StreamController<List<Group>> _streamController =
      StreamController<List<Group>>.broadcast();

  /// A networked [Group] repository
  /// Takes the [url] of the endpoint
  NetworkedGroupRepository(this.authenticationRepository);

  @override
  Future<Group?> addGroup(Group group) async {
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
      body: jsonEncode(group.toJson()),
    );
    if (response.statusCode != 201) {
      return null;
    }

    final Group newGroup = Group.fromJson(jsonDecode(response.body));
    _groups.add(newGroup);
    _streamController.add(List<Group>.of(_groups));
    return newGroup;
  }

  @override
  Future<Group?> editGroup(Group group) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.put(
      Uri.parse('$url$endpoint${group.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${await authenticationRepository.getToken()}'
      },
      body: jsonEncode(group.toJson()),
    );
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json group
      // edit local cache
      int index = _groups.indexWhere((element) => element.id == group.id);
      if (index == -1) {
        // could not find the group id
        throw GroupNotFoundException(id: group.id ?? -1);
      }
      _groups[index] = group;
      _streamController.add(List.from(_groups));
      return Group.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw GroupNotFoundException(id: group.id ?? -1);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint${group.id}', statuscode: response.statusCode);
    }
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  Future<Group> getGroup(int id) async {
    String? url = await authenticationRepository.getUrl();
    if (url == null) {
      throw Exception('No url');
    }
    Response response = await http.get(Uri.parse('$url$endpoint$id'),
        headers: <String, String>{
          'Authorization': 'Token ${await authenticationRepository.getToken()}'
        });
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json group
      return Group.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw GroupNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '$url$endpoint$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Group>> getGroups(int classId) async {
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
      // should be a list of json groups
      Iterable l = jsonDecode(response.body);
      // make json list into Group list
      _groups = List<Group>.from(l.map((json) => Group.fromJson(json)));
      // ship it down the stream
      _streamController.add(List<Group>.of(_groups, growable: false));
      return List<Group>.of(_groups);
    }
    throw ConnectionFailedException(
        url: '$url$endpoint?class_id=$classId',
        statuscode: response.statusCode);
  }

  @override
  Stream<List<Group>> get groups => _streamController.stream;
}
