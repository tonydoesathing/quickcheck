import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';
import 'package:quickcheck/widgets/student_assessment_table.dart';

class HomePage extends StatelessWidget {
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
        onPressed: () {},
        label: const Text("Add Assessment"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: StudentAssessmentTable(students: [
              for (int i = 0; i < 10; i++) Student(id: i, name: 'Student $i')
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
