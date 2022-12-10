import 'package:equatable/equatable.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/model/group.dart';

/// The data model for an assessment.
/// Consists of an id, a name, and a map between a student/group and their score in the assessment.
class Assessment extends Equatable {
  /// The id of the assessment
  final int? id;

  /// Name of the assessment
  final String name;

  /// Maps from Student/Group to assessment score
  final Map<dynamic, int> scoreMap;

  /// Create an [Assessment]
  ///
  /// The [name] and [scoreMap] must not be null
  const Assessment({this.id, required this.name, required this.scoreMap});

  /// Returns a new Assessment with specified changes
  Assessment copyWith({
    int? id,
    String? name,
    Map<dynamic, int>? scoreMap,
  }) {
    return Assessment(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreMap: scoreMap ?? this.scoreMap,
    );
  }

  /// Returns an assessment from a JSON String
  factory Assessment.fromJson(Map<String, dynamic> json) {
    // create scoremap from studentscore and groupscore
    final Map<dynamic, int> scoremap = {};
    (json['studentscore_set'] as List).forEach(
      (element) {
        // element is a {"score", "student", "assessment"} map
        scoremap[Student.fromJson(element["student"])] = element["score"];
      },
    );
    (json['groupscore_set'] as List).forEach(
      (element) {
        // element is a {"score", "group", "assessment"} map
        scoremap[Group.fromJson(element["group"])] = element["score"];
      },
    );
    return Assessment(id: json['id'], name: json['name'], scoreMap: scoremap);
  }

  /// Returns a JSON representation of an [Assessment]
  Map<String, dynamic> toJson() {
    final List studentScores = [];
    final List groupScores = [];
    scoreMap.forEach((key, value) {
      if (key is Student) {
        studentScores.add({"student_id": key.id, "score": value});
      } else if (key is Group) {
        groupScores.add({"group_id": key.id, "score": value});
      }
    });
    return {
      if (id != null) 'id': id,
      'name': name,
      'student_scores': studentScores,
      'group_scores': groupScores
    };
  }

  @override
  List<Object?> get props => [id, name, scoreMap];
}
