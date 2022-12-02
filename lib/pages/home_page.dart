import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/home_page_bloc.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/pages/add_assessment_page.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';

/// The home page of the app, which displays a table of the students and their assessment results
class HomePage extends StatelessWidget {
  /// The home page of the app, which displays a table of the students and their assessment results
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageBloc(context.read<StudentRepository>(),
          context.read<AssessmentRepository>())
        ..add(LoadStudentTableEvent()),
      child: BlocBuilder<HomePageBloc, HomePageState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("QuickCheck"),
              actions: [
                TextButton(
                    onPressed: () {
                      context
                          .read<StudentRepository>()
                          .addStudent(Student(name: "meow"));
                    },
                    child: const Text("Add Student"))
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                if (state is DisplayStudentTable) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAssessmentPage(
                              students: state.students,
                              callback: (assessment) {
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
            ),
            body: (state is DisplayStudentTable)
                ? Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: StudentAssessmentTable(
                            students: state.students,
                            assessments: state.assessments),
                      ),
                    ),
                  )
                : Center(
                    child: Text("Loading"),
                  ),
          );
        },
      ),
    );
  }
}
