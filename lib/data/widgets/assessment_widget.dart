import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';

class AssessmentWidget extends StatelessWidget {
  final Student student;
  const AssessmentWidget({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(student.name),
        Row(
          children: [],
        )
      ],
    );
  }
}
