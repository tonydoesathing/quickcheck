// Make HomePageBloc > Bloc, HomePageEvent > Equatable, HomePageState > Equatable.
// Bloc takes in a StudentRepository and an AssessmentRepository in its
// constructor, and initialize it with the LoadingStudentTable state.
// Events:

//     LoadStudentTableEvent
//     States:
//     LoadingStudentTable (displays nothing)
//     DisplayStudentTable (displays table of students and their assessments)

// on LoadStudentTableEvent, follow this pattern:
// on<DisplayReminders>( (event, emit) async { emit(HomeLoaded(event.reminders,
// event.selected)); await emit.forEach(_reminderRepository.reminders, onData:
// (List<Reminder> data) { return HomeLoaded(data, event.selected); }); },
// transformer: restartable(), );
// Emit DisplayStudentTable then listen for stream changes; the restartable
// transformer allows only one of these listens to be active at a time, so we
// can process other events as well.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../data/model/assessment.dart';
import '../data/model/student.dart';
import '../data/repository/local_assessment_repository.dart';

class HomePageBloc extends Bloc {
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;

  HomePageBloc(this.studentRepository, this.assessmentRepository)
      : super(LoadingStudentTable) {
    on<LoadStudentTableEvent>(
      (event, emit) async {
        emit(LoadingStudentTable);
        var students;
        var assessments;
        // need to pass list of students and assessments to DisplayStudentTable
        await emit.forEach(studentRepository.students,
            onData: (List<Student> data) {
          students = data;
        });
        await emit.forEach(assessmentRepository.assessments,
            onData: (List<Assessment> data) {
          assessments = data;
        });
        emit(DisplayStudentTable(students, assessments));
      },
      transformer: restartable(),
    );
  }
}

class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

class LoadStudentTableEvent extends HomePageEvent {}

class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

class LoadingStudentTable extends HomePageState {}

class DisplayStudentTable extends HomePageState {
  final List<Student> students;
  final List<Assessment> assessments;

  const DisplayStudentTable(this.students, this.assessments);
}
