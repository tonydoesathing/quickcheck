import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/student.dart';

/// The data model for an assessment.
/// Consists of an id, a name, and a map between a student and their score in the assessment.
class Assessment extends Equatable {
  /// The id of the assessment
  final int? id;

  /// Name of the assessment
  final String name;

  /// Maps from Student to assessment score
  final Map<Student, int> scoreMap;

  /// Create an [Assessment]
  ///
  /// The [name] and [scoreMap] must not be null
  const Assessment({this.id, required this.name, required this.scoreMap});

  /// Returns a new Assessment with specified changes
  Assessment copyWith({
    int? id,
    String? name,
    Map<Student, int>? scoreMap,
  }) {
    return Assessment(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreMap: scoreMap ?? this.scoreMap,
    );
  }

  @override
  List<Object?> get props => [id, name, scoreMap];
}
