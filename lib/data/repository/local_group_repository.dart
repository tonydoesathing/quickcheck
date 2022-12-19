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
  Future<Group?> addGroup(Group group) async {
    try {
      Group newGroup = group.copyWith(id: group.id ?? _groups.length + 1);
      _groups.add(newGroup);
      _streamController.add(List<Group>.of(_groups));
      return newGroup;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Group?> editGroup(Group group) async {
    int index = _groups.indexWhere((element) => element.id == group.id);
    if (index == -1) {
      return null;
    }
    _groups[index] = group;
    _streamController.add(List.from(_groups));
    return group;
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

  /// Get list of groups for a class
  Future<List<Group>> getGroups(int classId) async {
    return List<Group>.of(_groups.where((group) => group.classId == classId));
  }

  @override
  Stream<List<Group>> get groups {
    return _streamController.stream;
  }
}
