import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/home_page_bloc.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/pages/add_assessment_page.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:quickcheck/pages/add_student_page.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';
import 'package:quickcheck/widgets/group_assessment_table.dart';

/// The home page of the app, which displays a table of the students and their assessment results
class HomePage extends StatelessWidget {
  /// The home page of the app, which displays a table of the students and their assessment results
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create a HomePageBloc from the repositories and have it load from them
    return BlocProvider(
      create: (context) => HomePageBloc(context.read<StudentRepository>(),
          context.read<AssessmentRepository>(), context.read<GroupRepository>())
        ..add(LoadStudentTableEvent()),
      // On new state changes of the HomePageBloc, re-render the page
      child: BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("QuickCheck"),
              actions: [
                TextButton(
                    onPressed: () {
                      // on AddStudent, navigate to the AddStudentPage
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddStudentPage(callback: (student) {
                              // on save button in AddStudentPage, add the student to the repo
                              context
                                  .read<StudentRepository>()
                                  .addStudent(student);
                            }),
                          ));
                    },
                    child: const Text("Add Student"))
              ],
            ),
            floatingActionButton: state.students.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () {
                      // if we're not loading:
                      if (state is DisplayStudentTable) {
                        // Add Assessment button should take us to the AddAssessmentPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAssessmentPage(
                                    students: state.students,
                                    callback: (assessment) {
                                      // on save of assessment, add to the repo
                                      context
                                          .read<AssessmentRepository>()
                                          .addAssessment(assessment);
                                    },
                                  )),
                        );
                      }
                    },
                    label: const Text("Add Assessment"),
                    icon: const Icon(Icons.add),
                  )
                : null,
            // render the table if not loading
            body: (state is DisplayStudentTable)
                ? Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: GroupAssessmentTable(
                            students: state.students,
                            assessments: state.assessments,
                            groups: state.groups),
                      ),
                    ),
                  )
                // render that we're loading if we're loading
                : const Center(
                    child: Text("Loading"),
                  ),
          );
        },
      ),
    );
  }
}
