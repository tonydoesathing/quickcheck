import 'package:quickcheck/data/model/class.dart';

/// Abstract definition of a repository for [Class]es
/// Has a subscribable Stream to listen for changes to the list
abstract class ClassRepository {
  /// Returns a list of Classes whenever they're changed
  Stream<List<Class>> get classes;

  /// Disposes of the StreamController
  void dispose();

  /// Returns a list of Classes
  Future<List<Class>> getClasses();

  /// Returns a Class from an ID
  Future<Class> getClass(int id);

  /// Tries to add class to repository and returns the id or an error
  Future<int> addClass(Class clss);
}

/// [Class] with id of [id] could not be found in datastore
class ClassNotFoundException implements Exception {
  int id;

  /// Exception: [Class] with id of [id] could not be found in datastore
  ClassNotFoundException({required this.id});

  @override
  String toString() {
    return "No class found with ID $id";
  }
}
