import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/class_home_page_bloc.dart';
import 'package:quickcheck/bloc/home_page_bloc.dart';
import 'package:quickcheck/data/model/class.dart';
import 'package:quickcheck/data/model/group.dart';
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
              surfaceTintColor: Colors.white,
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
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (state is LoadingClassGroupTable)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ),
                // Table
                Row(
                  children: [
                    Expanded(
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
                                            .add(EditStudentEvent(student));
                                      },
                                    )),
                          );
                        },
                        onGroupClick: (group) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (pageContext) => AddGroupPage(
                                      callback: (g) {
                                        // on save of group, edit the group
                                        context
                                            .read<ClassHomePageBloc>()
                                            .add(EditGroupEvent(g));
                                      },
                                      students: state.students,
                                      group: group,
                                    )),
                          );
                        },
                        onAssessmentClick: (assessment) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (pageContext) => AddAssessmentPage(
                                      groups: state.groups,
                                      students: state.students,
                                      assessment: assessment,
                                      callback: (assessment) {
                                        // on save of assessment, edit the assessment
                                        context.read<ClassHomePageBloc>().add(
                                            EditAssessmentEvent(assessment));
                                      },
                                    )),
                          );
                        },
                      ),
                    )
                  ],
                ),
                // ask to add a student or group
                if (state.students.isEmpty && state is DisplayClassGroupTable)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Text(
                                  // ask to add a student or group if there aren't any
                                  (state.students.isEmpty &&
                                          state.groups.isEmpty)
                                      ? "Add a student or group!"
                                      : "Add a student!",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                  overflow: TextOverflow.clip,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, top: 2),
                              child: Icon(
                                size: 33,
                                Icons.arrow_upward,
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .color,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.assessments.isEmpty &&
                    state.students.isNotEmpty &&
                    state is DisplayClassGroupTable)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          // Ask to add an assessment
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    "Add an Assessment!",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 75.0),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 33,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .color,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
