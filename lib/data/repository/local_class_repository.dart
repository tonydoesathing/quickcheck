import 'dart:async';

import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/class_repository.dart';

/// An implementation of the [ClassRepository] making use of a networked datastore.
class LocalClassRepository implements ClassRepository {
  /// Stream used to update listeners with changes
  final StreamController<List<Class>> _streamController =
      StreamController<List<Class>>.broadcast();

  /// the local list of classes
  final List<Class> _classes = [];

  @override
  Future<Class?> addClass(Class clss) async {
    final Class newClass = clss.copyWith(id: _classes.length);
    _classes.add(newClass);
    _streamController.add(_classes.toList());

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
    for (Class c in _classes) {
      if (c.id == id) {
        return c;
      }
    }
    throw ClassNotFoundException(id: id);
  }

  @override
  Future<List<Class>> getClasses() async {
    List<Class> classes = _classes.toList();
    _streamController.add(classes);
    return classes;
  }
}
