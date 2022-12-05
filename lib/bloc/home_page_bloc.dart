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

/// The Business Logic Component for the HomePage.
/// Start off rendering a LoadingStudentTable state. Send a LoadStudentTableEvent off the bat
/// to pull resources from the repositories to populate the table and emit a DisplayStudentTable
/// state to display the table. Then, Add a DisplayStudentTableEvent to to continuously listen
/// for changes to the repositories and emit a DisplayStudentTable state each time.
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;

  HomePageBloc(this.studentRepository, this.assessmentRepository)
      : super(const LoadingStudentTable([], [])) {
    on<LoadStudentTableEvent>(
      (event, emit) async {
        // fetch required info
        final List<Student> students = await studentRepository.getStudents();
        final List<Assessment> assessments =
            await assessmentRepository.getAssessments();
        // request to display the info and subscribe to repo changes
        add(DisplayStudentTableEvent(students, assessments));
      },
    );

    on<DisplayStudentTableEvent>(
      (event, emit) async {
        // display the table
        emit(DisplayStudentTable(event.students, event.assessments));

        // combine repository streams into one
        HomePageBloc theBloc = this;
        await emit.forEach(
          StreamGroup.mergeBroadcast(
              [studentRepository.students, assessmentRepository.assessments]),
          onData: (data) {
            // check to see what kind of event got sent through the stream
            if (data is List<Student>) {
              // there was an update to the student repository
              // emit DisplayStudentTable using the student data and grabbing the assessments
              // from the current state
              return DisplayStudentTable(data, state.assessments);
            } else if (data is List<Assessment>) {
              // there was an update to the assessment repository
              // emit DisplayStudentTable using the assessment data and grabbing the students
              // from the current state
              return DisplayStudentTable(state.students, data);
            }
            // there was an event that there shouldn't've been
            throw Exception("Received unknown event on stream");
          },
        );
      },
      // this makes it so if there's another DisplayStudentTableEvent, it'll close
      // this one and start a new one (so we're not doing a ton of emissions)
      transformer: restartable(),
    );
  }
}

/// Requests/events for the HomePage
class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

/// Request to fetch resources from repositories
class LoadStudentTableEvent extends HomePageEvent {}

/// Request to display resources from repositories and listen for changes
class DisplayStudentTableEvent extends HomePageEvent {
  /// List of students to render
  final List<Student> students;

  /// List of assignments to render
  final List<Assessment> assessments;

  /// Request to display resources from repositories and listen for changes
  const DisplayStudentTableEvent(this.students, this.assessments);

  @override
  List<Object> get props => [students, assessments];
}

/// State for the HomePage
class HomePageState extends Equatable {
  /// List of students to render
  final List<Student> students;

  /// List of assignments to render
  final List<Assessment> assessments;

  /// State for the HomePage
  const HomePageState(this.students, this.assessments);

  @override
  List<Object> get props => [students, assessments];
}

/// State to show that it's loading the resources
class LoadingStudentTable extends HomePageState {
  /// State to show that it's loading the resources
  const LoadingStudentTable(super.students, super.assessments);
}

/// State to display the resouces once loaded
class DisplayStudentTable extends HomePageState {
  /// State to display the resouces once loaded
  const DisplayStudentTable(super.students, super.assessments);
}
