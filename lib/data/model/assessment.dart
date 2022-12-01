import 'package:equatable/equatable.dart';

class Assessment extends Equatable {
  final int id;
  final String name;
  final Map scoreMap;

  const Assessment(
      {required this.id, required this.name, required this.scoreMap});

  Assessment copyWith({
    int? id,
    String? name,
    Map? scoreMap,
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
