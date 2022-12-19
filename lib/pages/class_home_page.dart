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

  /// generate the list of groups and students
  Widget _studentList(ClassHomePageState state) {
    List<Student> ungroupedStudents = [];
    for (Student student in state.students) {
      if (student.groups == null || student.groups!.isEmpty) {
        ungroupedStudents.add(student);
      }
    }
    List elements = [];
    for (Group g in state.groups) {
      elements.add(g);
      for (Student s in g.members) {
        elements.add(s);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 0, 8),
      child: ListView.builder(
        itemCount: elements.length +
            ungroupedStudents.length +
            (ungroupedStudents.isEmpty
                ? 0
                : 1), // elements + ungrouped, + 1 if ungrouped
        itemBuilder: (context, index) {
          // elements
          if (index < elements.length) {
            var element = elements[index];
            if (element is Group) {
              return Container(
                alignment: Alignment.centerLeft,
                height: 44,
                child: Text(
                  element.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                ),
              );
            } else if (element is Student) {
              return Container(
                alignment: Alignment.centerLeft,
                height: 44,
                child: Row(children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Text(element.name, overflow: TextOverflow.fade))
                ]),
              );
            }
          }
          // ungrouped title
          if (index == elements.length) {
            return Padding(
              padding: EdgeInsets.only(top: elements.isEmpty ? 0.0 : 44.0),
              child: Container(
                alignment: Alignment.centerLeft,
                height: 44,
                child: Text(
                  "Ungrouped",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.fade,
                ),
              ),
            );
          }
          // ungrouped
          return Container(
            alignment: Alignment.centerLeft,
            height: 44,
            child: Row(children: [
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Text(
                      ungroupedStudents[index - elements.length - 1].name,
                      overflow: TextOverflow.fade))
            ]),
          );
        },
      ),
    );
  }

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
                ? (state.students.isEmpty && state.groups.isEmpty)
                    // ask to add student/group
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 100, right: 12.0),
                                child: Text(
                                  "Add a student or group!",
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
                      )
                    : Row(
                        children: [
                          if ((state.groups.isNotEmpty ||
                                  state.students.isNotEmpty) &&
                              state.assessments.isEmpty)
                            // display list of students
                            Expanded(child: _studentList(state)),
                          if (state.assessments.isNotEmpty)
                            // display the table if we have everything
                            Expanded(
                              child: GroupAssessmentTable(
                                assessments: state.assessments,
                                groups: state.groups,
                                students: state.students,
                              ),
                            ),
                          if (state.students.isEmpty)
                            // prompt to add student
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12, right: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0),
                                            child: Text(
                                              "Add a student!",
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
                                              const EdgeInsets.only(top: 2.0),
                                          child: Icon(
                                            Icons.arrow_upward,
                                            size: 33,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headlineMedium!
                                                .color,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (state.students.isNotEmpty &&
                              state.assessments.isEmpty)
                            Expanded(
                              child: Column(
                                // Ask to add an assessment
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          "Add an Assessment!",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 75.0),
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
                            )
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
