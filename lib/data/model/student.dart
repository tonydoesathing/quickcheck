import 'dart:convert';

import 'package:equatable/equatable.dart';

/// The data model for a student
/// Consists of an id and a name
class Student extends Equatable {
  /// the id of the student
  final int? id;

  /// the name of the student
  final String name;

  /// the groups a student is in
  final List<int>? groups;

  /// The class the student belongs to
  final int classId;

  /// Create a [Student]
  ///
  /// The [name] must not be null
  const Student({this.id, required this.name, this.groups, this.classId = 1});

  // Returns a new Student with specified changes
  Student copyWith({
    int? id,
    String? name,
    List<int>? groups,
    int? classId,
  }) {
    return Student(
        id: id ?? this.id,
        name: name ?? this.name,
        groups: groups ?? this.groups,
        classId: classId ?? this.classId);
  }

  /// Returns a [Student] from a json map
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        name: json['name'],
        id: json['id'],
        groups:
            (json['groups'] as List).map((element) => element as int).toList(),
        classId: json['class_id'] ?? 1);
  }

  /// Returns a JSON representation of a Student
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'name': name,
      if (groups != null) 'groups': groups,
      'class_id': classId
    };
  }

  @override
  List<Object?> get props => [id, name, groups, classId];
}
