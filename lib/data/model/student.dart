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

  /// Create a [Student]
  ///
  /// The [name] must not be null
  const Student({this.id, required this.name, this.groups});

  // Returns a new Student with specified changes
  Student copyWith({
    int? id,
    String? name,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  /// Returns a [Student] from a json map
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        name: json['name'],
        id: json['id'],
        groups:
            (json['groups'] as List).map((element) => element as int).toList());
  }

  /// Returns a JSON representation of a Student
  String toJson() {
    return jsonEncode(<String, String>{
      if (id != null) 'id': id.toString(),
      'name': name,
      if (groups != null) 'groups': groups.toString()
    });
  }

  @override
  List<Object?> get props => [id, name];
}
