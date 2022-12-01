import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final int? id;
  final String name;

  const Student({required this.id, required this.name});

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
