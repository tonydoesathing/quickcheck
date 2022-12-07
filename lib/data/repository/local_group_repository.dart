import 'dart:async';

import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/repository/group_repository.dart';

/// The LocalGroupRepository is an implementation of the [GroupRepository] making use of an in-memory datastore.
class LocalGroupRepository extends GroupRepository {
  /// Stream used to update listeners with changes
  final StreamController<List<Group>> _streamController =
      StreamController<List<Group>>.broadcast();

  /// The datastore for Groups
  final List<Group> _groups = [];

  @override

  /// Add Group to _groups list.
  Future<bool> addGroup(Group group) async {
    try {
      Group newGroup = group.copyWith(id: group.id ?? _groups.length + 1);
      _groups.add(newGroup);
      _streamController.add(List<Group>.of(_groups));
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

  /// Get group by ID.
  Future<Group> getGroup(int id) async {
    for (Group group in _groups) {
      if (group.id == id) {
        return group;
      }
    }
    throw GroupNotFoundException(id: id);
  }

  @override

  /// Get list of groups
  Future<List<Group>> getGroups() async {
    _streamController.add(List<Group>.of(_groups));
    return List<Group>.of(_groups);
  }

  @override
  Stream<List<Group>> get groups {
    return _streamController.stream;
  }
}
