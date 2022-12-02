import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';

class AddAssessmentPage extends StatefulWidget {
  final Function(Assessment)? callback;
  final List<Student> students;
  const AddAssessmentPage({Key? key, this.callback, required this.students})
      : super(key: key);

  @override
  State<AddAssessmentPage> createState() => _AddAssessmentPageState();
}

class _AddAssessmentPageState extends State<AddAssessmentPage> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assessment"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Name (optional)"),
            ),
          ]),
        ),
      ),
    );
  }
}
