import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import '../data/model/assessment.dart';
import '../data/model/student.dart';
import '../data/model/group.dart';

/// The Business Logic Component for the ClassHomePage.
class ClassHomePageBloc extends Bloc<ClassHomePageEvent, ClassHomePageState> {
  final Class theClass;
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;
  final GroupRepository groupRepository;

  ClassHomePageBloc(this.studentRepository, this.assessmentRepository,
      this.groupRepository, this.theClass)
      : super(const LoadingClassGroupTable([], [], [])) {
    on<LoadClassGroupTableEvent>(
      (event, emit) async {
        // fetch required info
        final List<Student> students =
            await studentRepository.getStudents(theClass.id!);
        final List<Assessment> assessments =
            await assessmentRepository.getAssessments(theClass.id!);
        final List<Group> groups =
            await groupRepository.getGroups(theClass.id!);

        emit(DisplayClassGroupTable(students, assessments, groups));
      },
    );

    on<AddStudentEvent>(
      (event, emit) async {
        // add the student to the repo
        try {
          emit(LoadingClassGroupTable(
              state.students, state.assessments, state.groups));
          final Student? student = await studentRepository
              .addStudent(event.student.copyWith(classId: theClass.id));

          if (student != null) {
            final List<Student> newStudents = List.from(state.students);
            newStudents.add(student);

            List<Group> newGroups = state.groups;
            // if there were groups added, update the groups and emit
            if (student.groups != null && student.groups!.isNotEmpty) {
              newGroups = state.groups.map<Group>(((element) {
                if (student.groups!.contains(element.id)) {
                  return element.copyWith(
                      members: List<Student>.from(element.members)
                        ..add(student));
                }
                return element;
              })).toList();
            }

            emit(DisplayClassGroupTable(
                newStudents, state.assessments, newGroups));
          } else {
            emit(DisplayClassGroupTableError(state.students, state.assessments,
                state.groups, Exception("Student addition failed")));
          }
        } catch (e) {
          // if there was an error, emit error state
          emit(DisplayClassGroupTableError(
              state.students, state.assessments, state.groups, e));
        }
      },
    );

    on<EditStudentEvent>(
      (event, emit) async {
        // add the student to the repo
        try {
          emit(LoadingClassGroupTable(
              state.students, state.assessments, state.groups));
          // get the student in the repo
          final Student oldStudent =
              await studentRepository.getStudent(event.student.id!);

          final Student? student = await studentRepository
              .editStudent(event.student.copyWith(classId: theClass.id));

          if (event.student.groups != null) {
            // add student to groups
            for (int groupId in event.student.groups!) {
              // get the group
              Group group = await groupRepository.getGroup(groupId);
              // if the student isn't in the group, add it
              int idx = group.members
                  .indexWhere((element) => element.id == event.student.id);
              if (idx == -1) {
                group.members.add(event.student);
                await groupRepository.editGroup(group);
              }
            }
            // remove student from old groups
            if (oldStudent.groups != null) {
              for (int id in oldStudent.groups!) {
                if (event.student.groups != null) {
                  if (!event.student.groups!.contains(id)) {
                    // get the group
                    Group group = await groupRepository.getGroup(id);
                    // remove the student
                    group.members.removeWhere(
                        (element) => element.id == event.student.id);
                    await groupRepository.editGroup(group);
                  }
                }
              }
            }
          }

          if (student != null) {
            final List<Student> newStudents =
                await studentRepository.getStudents(theClass.id!);
            final List<Assessment> newAssessments =
                await assessmentRepository.getAssessments(theClass.id!);
            final List<Group> newGroups =
                await groupRepository.getGroups(theClass.id!);
            emit(
                DisplayClassGroupTable(newStudents, newAssessments, newGroups));
          } else {
            emit(DisplayClassGroupTableError(state.students, state.assessments,
                state.groups, Exception("Student edit failed")));
          }
        } catch (e) {
          // if there was an error, emit error state
          emit(DisplayClassGroupTableError(
              state.students, state.assessments, state.groups, e));
        }
      },
    );

    on<AddGroupEvent>(
      (event, emit) async {
        try {
          emit(LoadingClassGroupTable(
              state.students, state.assessments, state.groups));
          // add the group to the repo
          final Group? group = await groupRepository
              .addGroup(event.group.copyWith(classId: theClass.id));
          if (group != null) {
            final List<Group> newGroups = List.from(state.groups);
            newGroups.add(group);
            List<Student> newStudents = state.students;
            final List<Assessment> newAssessments =
                List.from(state.assessments);
            // if there were students added, update the students and emit
            newStudents = newStudents.map<Student>(
              (element) {
                for (Student student in group.members) {
                  if (student.id == element.id) {
                    // fix assessements as well
                    for (Assessment assessment in newAssessments) {
                      if (assessment.scoreMap.containsKey(element)) {
                        assessment.scoreMap[student] =
                            assessment.scoreMap[element]!;
                        assessment.scoreMap.remove(element);
                      }
                    }
                    return student;
                  }
                }
                return element;
              },
            ).toList();

            emit(DisplayClassGroupTable(
                newStudents, state.assessments, newGroups));
          } else {
            emit(DisplayClassGroupTableError(state.students, state.assessments,
                state.groups, Exception("Group addition failed")));
          }
        } catch (e) {
          // if there was an error, emit error state
          emit(DisplayClassGroupTableError(
              state.students, state.assessments, state.groups, e));
        }
        // if there was an error, emit error state
      },
    );

    on<EditGroupEvent>(
      (event, emit) async {
        try {
          emit(LoadingClassGroupTable(
              state.students, state.assessments, state.groups));
          // edit the group in the repo
          final Group? group = await groupRepository
              .editGroup(event.group.copyWith(classId: theClass.id));

          if (group != null) {
            final List<Student> newStudents =
                await studentRepository.getStudents(theClass.id!);
            final List<Assessment> newAssessments =
                await assessmentRepository.getAssessments(theClass.id!);
            final List<Group> newGroups =
                await groupRepository.getGroups(theClass.id!);
            emit(
                DisplayClassGroupTable(newStudents, newAssessments, newGroups));
          } else {
            emit(DisplayClassGroupTableError(state.students, state.assessments,
                state.groups, Exception("Group edit failed")));
          }
        } catch (e) {
          // if there was an error, emit error state
          emit(DisplayClassGroupTableError(
              state.students, state.assessments, state.groups, e));
        }
      },
    );

    on<AddAssessmentEvent>(
      (event, emit) async {
        try {
          emit(LoadingClassGroupTable(
              state.students, state.assessments, state.groups));
          // add the assessment to the repo
          final Assessment? assessment = await assessmentRepository
              .addAssessment(event.assessment.copyWith(classId: theClass.id));

          if (assessment != null) {
            final List<Assessment> newAssessments =
                List.from(state.assessments);
            newAssessments.add(assessment);
            emit(DisplayClassGroupTable(
                state.students, newAssessments, state.groups));
          } else {
            emit(DisplayClassGroupTableError(state.students, state.assessments,
                state.groups, Exception("Assessment addition failed")));
          }
        } catch (e) {
          // if there was an error, emit error state
          emit(DisplayClassGroupTableError(
              state.students, state.assessments, state.groups, e));
        }
      },
    );
  }
}

/// Requests/events for the HomePage
class ClassHomePageEvent extends Equatable {
  const ClassHomePageEvent();

  @override
  List<Object> get props => [];
}

/// Request to fetch resources from repositories
class LoadClassGroupTableEvent extends ClassHomePageEvent {}

/// Add a student to a class
class AddStudentEvent extends ClassHomePageEvent {
  /// The [Student] to add
  final Student student;

  /// Add a [student] to the class
  const AddStudentEvent(this.student);

  @override
  List<Object> get props => [student];
}

/// Edit a student in a class
class EditStudentEvent extends ClassHomePageEvent {
  /// The [Student] to add
  final Student student;

  /// Edit a [student] in the class
  const EditStudentEvent(this.student);

  @override
  List<Object> get props => [student];
}

/// Add a group to a class
class AddGroupEvent extends ClassHomePageEvent {
  /// The [Group] to add
  final Group group;

  /// Add a [group] to the class
  const AddGroupEvent(this.group);

  @override
  List<Object> get props => [group];
}

/// Add a group to a class
class EditGroupEvent extends ClassHomePageEvent {
  /// The [Group] to edit
  final Group group;

  /// Edit a [group] in the class
  const EditGroupEvent(this.group);

  @override
  List<Object> get props => [group];
}

/// Add an assessment to a class
class AddAssessmentEvent extends ClassHomePageEvent {
  /// The [Assessment] to add
  final Assessment assessment;

  /// Add an [assessment] to the class
  const AddAssessmentEvent(this.assessment);

  @override
  List<Object> get props => [assessment];
}

/// State for the ClassHomePage
class ClassHomePageState extends Equatable {
  /// List of students to render
  final List<Student> students;

  /// List of assignments to render
  final List<Assessment> assessments;

  /// List of groups to render
  final List<Group> groups;

  /// State for the ClassHomePage
  const ClassHomePageState(this.students, this.assessments, this.groups);

  @override
  List<Object> get props => [students, assessments, groups];
}

/// State to show that it's loading the resources
class LoadingClassGroupTable extends ClassHomePageState {
  /// State to show that it's loading the resources
  const LoadingClassGroupTable(super.students, super.assessments, super.groups);
}

/// State to display the resouces once loaded
class DisplayClassGroupTable extends ClassHomePageState {
  /// State to display the resouces once loaded
  const DisplayClassGroupTable(super.students, super.assessments, super.groups);
}

/// State to display if there's an error
class DisplayClassGroupTableError extends ClassHomePageState {
  /// the error
  final Object error;

  /// State to display if there's an error
  const DisplayClassGroupTableError(
      super.students, super.assessments, super.groups, this.error);

  @override
  List<Object> get props => [...super.props, error];
}
