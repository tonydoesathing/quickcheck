// In main(), initialize a StudentRepository and an AssessmentRepository
// (using the in-memory versions), and pass them into App via constructor.
// Then, use MultiRepositoryProvider in App to provide the repositories to the
// context.

// Override App's dispose function to dispose of the repositories.

// Using BlocProvider, create new HomePageBloc for HomePage
// (using context.read() to give it the required repositories),
// then make use of a BlocProvider to provide the bloc.
// When LoadingStudentTable, display nothing in the body.
// When DisplayStudentTable, display the StudentAssessmentTable widget.

// Update the onSave callback for AddStudent to add the Student to the
// StudentRepository

import 'package:flutter/material.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/data/repository/local_group_repository.dart';
import 'package:quickcheck/data/repository/networked_student_repository.dart';
import 'package:quickcheck/pages/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repository/assessment_repository.dart';
import 'data/repository/local_student_repository.dart';
import 'data/repository/local_assessment_repository.dart';
import 'data/repository/student_repository.dart';

void main() {
  const String endpointURL = "http://127.0.0.1:8000/api/";

  final StudentRepository studentRepository =
      NetworkedStudentRepository(endpointURL);
  final AssessmentRepository assessmentRepository = LocalAssessmentRepository();
  final GroupRepository groupRepository = LocalGroupRepository();

  runApp(App(
    studentRepository: studentRepository,
    assessmentRepository: assessmentRepository,
    groupRepository: groupRepository,
  ));
}

/// The main app of the application; serves as a wrapper for a MaterialApp and loads HomePage
class App extends StatelessWidget {
  final StudentRepository studentRepository;
  final AssessmentRepository assessmentRepository;
  final GroupRepository groupRepository;

  const App(
      {Key? key,
      required this.studentRepository,
      required this.assessmentRepository,
      required this.groupRepository})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StudentRepository>.value(
          value: studentRepository,
        ),
        RepositoryProvider<GroupRepository>.value(
          value: groupRepository,
        ),
        RepositoryProvider<AssessmentRepository>.value(
          value: assessmentRepository,
        ),
      ],
      child: MaterialApp(
        title: 'Home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
