import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/pages/add_assessment_page.dart';

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddAssessmentPage(students: [
                      for (int i = 0; i < 10; i++) Student(id: i, name: '$i')
                    ])),
          );
        },
        label: const Text("Add Assessment"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [const Text("Table goes here")],
        ),
      ),
    );
  }
}
