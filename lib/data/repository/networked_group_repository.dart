import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:http/http.dart' as http;

import 'networked_student_repository.dart';

/// A networked [Group] repository
class NetworkedGroupRepository extends GroupRepository {
  /// the URL of the API
  final String url;

  /// local cache of groups
  List<Group> _groups = [];

  /// Stream used to update listeners with changes
  final StreamController<List<Group>> _streamController =
      StreamController<List<Group>>.broadcast();

  /// A networked [Group] repository
  /// Takes the [url] of the endpoint
  NetworkedGroupRepository(this.url);

  @override
  Future<bool> addGroup(Group group) async {
    Response response = await http.post(
      Uri.parse('${url}groups/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(group.toJson()),
    );
    if (response.statusCode != 201) {
      return false;
    }

    // add the newly-created group
    // as a workaround for the addGroup API request not returning a full group
    // (only student id's not objects), I'm just copying over the ID into the O.G. group
    // just delete workaround and uncomment normal code
    // starting workaround
    _groups.add(group.copyWith(id: jsonDecode(response.body)['id']));
    // normal code:
    // _groups.add(Group.fromJson(jsonDecode(response.body)));
    _streamController.add(List<Group>.of(_groups));
    return true;
  }

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  Future<Group> getGroup(int id) async {
    Response response = await http.get(Uri.parse('${url}groups/$id'));
    if (response.statusCode == 200 && response.body != "400") {
      // the body should be json group
      return Group.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw GroupNotFoundException(id: id);
    } else {
      throw ConnectionFailedException(
          url: '${url}groups/$id', statuscode: response.statusCode);
    }
  }

  @override
  Future<List<Group>> getGroups(int classId) async {
    Response response = await http.get(Uri.parse('${url}groups/'));
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
        url: '${url}groups/', statuscode: response.statusCode);
  }

  @override
  Stream<List<Group>> get groups => _streamController.stream;
}
