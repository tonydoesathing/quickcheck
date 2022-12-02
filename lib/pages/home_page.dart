import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/pages/add_assessment_page.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';

/// The home page of the app, which displays a table of the students and their assessment results
class HomePage extends StatelessWidget {
  /// The home page of the app, which displays a table of the students and their assessment results
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuickCheck"),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Add Student"))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddAssessmentPage(
                      // pass in the list of students; this is fictional
                      students: [
                        for (int i = 0; i < 10; i++)
                          Student(id: i, name: 'Student $i')
                      ],
                      callback: (assessment) {
                        // this is where you'd save things
                      },
                    )),
          );
        },
        label: const Text("Add Assessment"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StudentAssessmentTable(

                /// made up list of students and assessments
                students: [
                  for (int i = 0; i < 10; i++)
                    Student(id: i, name: 'Student $i')
                ], assessments: [
              for (int i = 0; i < 10; i++)
                Assessment(id: i, name: 'Assessment $i', scoreMap: {
                  for (var el in [
                    for (int j = 0; j < 10; j++)
                      Student(id: j, name: 'Student $j')
                  ])
                    el: el.id! % 5
                })
            ]),
          ),
        ),
      ),
    );
  }
}
