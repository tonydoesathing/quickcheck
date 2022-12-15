import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';

/// The data model for a class
/// Consists of an id, name, list of [Student]s, list of [Group]s, list of [Assessment]s
class Class extends Equatable {
  /// The id of the class
  final int? id;

  /// The name of the class
  final String name;

  /// The students in the class
  final List<Student> students;

  /// The groups in the class
  final List<Group> groups;

  /// The assessments in the class
  final List<Assessment> assessments;

  /// Create a [Class]
  ///
  /// The [name] must not be null
  const Class(
      {this.id,
      required this.name,
      this.students = const [],
      this.groups = const [],
      this.assessments = const []});

  // Returns a new Class with specified changes
  Class copyWith(
      {int? id,
      String? name,
      List<Student>? students,
      List<Group>? groups,
      List<Assessment>? assessments}) {
    return Class(
        id: id ?? this.id,
        name: name ?? this.name,
        students: students ?? this.students,
        groups: groups ?? this.groups,
        assessments: assessments ?? this.assessments);
  }

  /// Returns a [Class] from a json map
  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      name: json['name'],
      id: json['id'],
      students: json['student_set'] != null
          ? (json['student_set'] as List)
              .map((element) => Student.fromJson(element))
              .toList()
          : [],
      groups: json['group_set'] != null
          ? (json['group_set'] as List)
              .map((element) => Group.fromJson(element))
              .toList()
          : [],
      assessments: json['assessment_set'] != null
          ? (json['assessment_set'] as List)
              .map((element) => Assessment.fromJson(element))
              .toList()
          : [],
    );
  }

  /// Returns a JSON representation of a [Class]
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name, students, groups, assessments];
}
