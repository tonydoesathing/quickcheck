import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/student.dart';

class Assessment extends Equatable {
  final int id;
  final String name;
  // Maps from Student to assessment score
  final Map<Student, int> scoreMap;

  const Assessment(
      {required this.id, required this.name, required this.scoreMap});

  // Returns a new Assessment with specified changes
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
