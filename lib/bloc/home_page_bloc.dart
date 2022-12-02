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

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../data/model/assessment.dart';
import '../data/model/student.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;

  HomePageBloc(this.studentRepository, this.assessmentRepository)
      : super(LoadingStudentTable()) {
    on<LoadStudentTableEvent>(
      (event, emit) async {
        print("Loading tables");
        // fetch required info
        final List<Student> students = await studentRepository.getStudents();
        final List<Assessment> assessments =
            await assessmentRepository.getAssessments();
        add(DisplayStudentTableEvent(students, assessments));
      },
      transformer: restartable(),
    );

    on<DisplayStudentTableEvent>(
      (event, emit) async {
        print("displaying tables");
        // combine repository streams into one
        HomePageBloc theBloc = this;
        await emit.forEach(
          StreamGroup.mergeBroadcast(
              [studentRepository.students, assessmentRepository.assessments]),
          onData: (data) {
            // check to see what kind of event got sent through the stream
            if (data is List<Student>) {
              List<Assessment> assessments;
              HomePageState state = theBloc.state;
              if (state is DisplayStudentTable) {
                assessments = state.assessments;
              } else {
                assessments = event.assessments;
              }
              return DisplayStudentTable(data, assessments);
            } else if (data is List<Assessment>) {
              List<Student> students;
              HomePageState state = theBloc.state;
              if (state is DisplayStudentTable) {
                students = state.students;
              } else {
                students = event.students;
              }
              return DisplayStudentTable(students, data);
            }
            throw Exception("Received unknown event on stream");
          },
        );
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

class DisplayStudentTableEvent extends HomePageEvent {
  final List<Student> students;
  final List<Assessment> assessments;

  const DisplayStudentTableEvent(this.students, this.assessments);

  @override
  List<Object> get props => [students, assessments];
}

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

  @override
  List<Object> get props => [students, assessments];
}
