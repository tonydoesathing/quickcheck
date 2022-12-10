import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/student.dart';

/// The data model for a group
/// Consists of an id, name and list of students
class Group extends Equatable {
  /// The id of the group
  final int? id;

  /// The name of the group
  final String name;

  /// The students int the group
  final List<Student> members;

  /// Create a [Group]
  ///
  /// The [name] must not be null
  /// The [members] must not be null
  const Group({this.id, required this.name, required this.members});

  // Returns a new Group with specified changes
  Group copyWith({
    int? id,
    String? name,
    List<Student>? members,
  }) {
    return Group(
        id: id ?? this.id,
        name: name ?? this.name,
        members: members ?? this.members);
  }

  /// Returns a [Group] from a json map
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
        name: json['name'],
        id: json['id'],
        members: (json['student_set'] as List)
            .map((element) => Student.fromJson(element))
            .toList());
  }

  /// Returns a JSON representation of a [Group]
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'student_set': members.map((student) => student.id).toList()
    };
  }

  @override
  List<Object?> get props => [id, name, members];
}
