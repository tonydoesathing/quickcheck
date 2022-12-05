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

  @override
  List<Object?> get props => [id, name, members];
}
