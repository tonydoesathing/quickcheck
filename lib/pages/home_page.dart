import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcheck/bloc/home_page_bloc.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/repository/assessment_repository.dart';
import 'package:quickcheck/data/repository/student_repository.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageBloc(context.read<StudentRepository>(),
          context.read<AssessmentRepository>())
        ..add(LoadStudentTableEvent()),
      child: Scaffold(
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
            context
                .read<AssessmentRepository>()
                .addAssessment(Assessment(name: "assessment 1", scoreMap: {
                  for (var el in [
                    for (int j = 0; j < 10; j++)
                      Student(id: j, name: 'Student ')
                  ])
                    el: el.id! % 5
                }));
          },
          label: const Text("Add Assessment"),
          icon: const Icon(Icons.add),
        ),
        body: BlocBuilder<HomePageBloc, HomePageState>(
          builder: (context, state) {
            if (state is DisplayStudentTable) {
              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: StudentAssessmentTable(
                        students: state.students,
                        assessments: state.assessments),
                  ),
                ),
              );
            }
            return Center(
              child: Text("Loading"),
            );
          },
        ),
      ),
    );
  }
}
