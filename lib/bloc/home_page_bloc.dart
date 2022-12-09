import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../data/model/assessment.dart';
import '../data/model/student.dart';
import '../data/model/group.dart';

/// The Business Logic Component for the HomePage.
/// Start off rendering a LoadingStudentTable state. Send a LoadStudentTableEvent off the bat
/// to pull resources from the repositories to populate the table and emit a DisplayStudentTable
/// state to display the table. Then, Add a DisplayStudentTableEvent to to continuously listen
/// for changes to the repositories and emit a DisplayStudentTable state each time.
class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;
  final GroupRepository groupRepository;

  HomePageBloc(
      this.studentRepository, this.assessmentRepository, this.groupRepository)
      : super(const LoadingStudentTable([], [], [])) {
    on<LoadStudentTableEvent>(
      (event, emit) async {
        // fetch required info
        final List<Student> students = await studentRepository.getStudents();
        final List<Assessment> assessments =
            await assessmentRepository.getAssessments();
        final List<Group> groups = await groupRepository.getGroups();
        // request to display the info and subscribe to repo changes
        add(DisplayStudentTableEvent(students, assessments, groups));
      },
    );

    on<DisplayStudentTableEvent>(
      (event, emit) async {
        // display the table
        emit(DisplayStudentTable(
            event.students, event.assessments, event.groups));

        // combine repository streams into one
        //HomePageBloc theBloc = this;
        await emit.forEach(
          StreamGroup.mergeBroadcast([
            studentRepository.students,
            assessmentRepository.assessments,
            groupRepository.groups
          ]),
          onData: (data) {
            // check to see what kind of event got sent through the stream
            if (data is List<Student>) {
              // there was an update to the student repository
              // emit DisplayStudentTable using the student data and grabbing the assessments
              // and groups from the current state
              return DisplayStudentTable(data, state.assessments, state.groups);
            } else if (data is List<Assessment>) {
              // there was an update to the assessment repository
              // emit DisplayStudentTable using the assessment data and grabbing the students
              // and groups from the current state
              return DisplayStudentTable(state.students, data, state.groups);
            } else if (data is List<Group>) {
              // there was an update to the group repository
              // emit DisplayStudentTable using the group data and grabbing the students
              // and assessments from the current state
              print(data);
              return DisplayStudentTable(
                  state.students, state.assessments, List<Group>.of(data));
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

  /// List of groups to render
  final List<Group> groups;

  /// Request to display resources from repositories and listen for changes
  const DisplayStudentTableEvent(this.students, this.assessments, this.groups);

  @override
  List<Object> get props => [students, assessments, groups];
}

/// State for the HomePage
class HomePageState extends Equatable {
  /// List of students to render
  final List<Student> students;

  /// List of assignments to render
  final List<Assessment> assessments;

  /// List of groups to render
  final List<Group> groups;

  /// State for the HomePage
  const HomePageState(this.students, this.assessments, this.groups);

  @override
  List<Object> get props => [students, assessments, groups];
}

/// State to show that it's loading the resources
class LoadingStudentTable extends HomePageState {
  /// State to show that it's loading the resources
  const LoadingStudentTable(super.students, super.assessments, super.groups);
}

/// State to display the resouces once loaded
class DisplayStudentTable extends HomePageState {
  /// State to display the resouces once loaded
  const DisplayStudentTable(super.students, super.assessments, super.groups);
}
