import 'package:equatable/equatable.dart';

/// The data model for a student
/// Consists of an id and a name
class Student extends Equatable {
  /// the id of the student
  final int? id;

  /// the name of the student
  final String name;

  /// Create a [Student]
  ///
  /// The [name] must not be null
  const Student({this.id, required this.name});

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

  @override
  List<Object?> get props => [id, name];
}
