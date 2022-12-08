import '../model/group.dart';

/// Abstract definition of a repository for [Group]s
/// Has a subscribable Stream to listen for changes to the list
abstract class GroupRepository {
  /// Returns a list of groups whenever they're changed
  Stream<List<Group>> get groups;

  /// Disposes of the StreamController
  void dispose();

  /// Returns a list of Groups
  Future<List<Group>> getGroups();

  /// Returns a group from an ID
  Future<Group> getGroup(int id);

  /// Tries to add group to repository and returns whether or not it was successful
  Future<bool> addGroup(Group group);
}

/// [Group] with id of [id] could not be found in datastore
class GroupNotFoundException implements Exception {
  final int id;

  /// Exception: [Group] with id of [id] could not be found in datastore
  const GroupNotFoundException({required this.id});

  @override
  String toString() {
    return "No group found with ID $id";
  }
}