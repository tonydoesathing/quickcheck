import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/class_home_page_bloc.dart';
import 'package:quickcheck/bloc/home_page_bloc.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/group_repository.dart';
import 'package:quickcheck/pages/add_assessment_page.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:quickcheck/pages/add_group_page.dart';
import 'package:quickcheck/pages/add_student_page.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';
import 'package:quickcheck/widgets/group_assessment_table.dart';

/// The home page of for a class which displays a table of the students/groups and their assessment results
class ClassHomePage extends StatelessWidget {
  final Class theClass;

  /// The home page of for a class which displays a table of the students/groups and their assessment results
  const ClassHomePage({Key? key, required this.theClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // create a HomePageBloc from the repositories and have it load from them
    return BlocProvider(
      create: (context) => ClassHomePageBloc(
          context.read<StudentRepository>(),
          context.read<AssessmentRepository>(),
          context.read<GroupRepository>(),
          theClass)
        ..add(LoadClassGroupTableEvent()),
      // On new state changes of the HomePageBloc, re-render the page
      child: BlocConsumer<ClassHomePageBloc, ClassHomePageState>(
        listener: (context, state) {
          if (state is DisplayClassGroupTableError) {
            throw state.error;
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(theClass.name),
              actions: [
                PopupMenuButton(
                    onSelected: (value) {
                      if (value == 0) {
                        // Add Student selected
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (pageContext) => AddStudentPage(
                                callback: (student) {
                                  // on save button in AddStudentPage, add the student
                                  context
                                      .read<ClassHomePageBloc>()
                                      .add(AddStudentEvent(student));
                                },
                                groups: state.groups,
                              ),
                            ));
                      } else if (value == 1) {
                        // Add Group selected

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (pageContext) => AddGroupPage(
                                  students: state.students,
                                  callback: (group) {
                                    // on save button in AddGroupPage, add the group
                                    context
                                        .read<ClassHomePageBloc>()
                                        .add(AddGroupEvent(group));
                                  }),
                            ));
                      }
                    },
                    itemBuilder: ((context) => [
                          PopupMenuItem(
                              value: 0,
                              child: Row(
                                children: const [Text("Add Student")],
                              )),
                          PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: const [Text("Add Group")],
                              )),
                        ])),
              ],
            ),
            floatingActionButton: state.students.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () {
                      // if we're not loading:
                      if (state is DisplayClassGroupTable) {
                        // Add Assessment button should take us to the AddAssessmentPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (pageContext) => AddAssessmentPage(
                                    groups: state.groups,
                                    students: state.students,
                                    callback: (assessment) {
                                      // on save of assessment, add the assessment
                                      context
                                          .read<ClassHomePageBloc>()
                                          .add(AddAssessmentEvent(assessment));
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
            body: (state is DisplayClassGroupTable)
                ? Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: GroupAssessmentTable(
                              assessments: state.assessments,
                              groups: state.groups,
                              students: state.students,
                              onStudentClick: (student) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (pageContext) => AddStudentPage(
                                            groups: state.groups,
                                            student: student,
                                            callback: (student) {
                                              // on save of student, edit the student
                                              context
                                                  .read<ClassHomePageBloc>()
                                                  .add(EditStudentEvent(
                                                      student));
                                            },
                                          )),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
