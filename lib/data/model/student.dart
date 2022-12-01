import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final int id;
  final String name;

  const Student({required this.id, required this.name});

  @override
  List<Object?> get props => [];
}
