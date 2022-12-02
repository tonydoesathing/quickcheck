import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/assessment_score.dart';

/// A table that displays students on the y-axis and assignments on the top column
/// Student names are the first column, and each column after that is their score for the associated assessment,
/// with the assessment name at the top
class StudentAssessmentTable extends StatelessWidget {
  final List<Student> students;
  final List<Assessment> assessments;

  /// Create a table from a list of [students] and a list of [assessments]
  const StudentAssessmentTable(
      {Key? key, required this.students, required this.assessments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: <DataColumn>[
        const DataColumn(
          label: Expanded(
            child: Text(
              '',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ),
        for (Assessment assessment in assessments)
          DataColumn(
            label: Expanded(
              child: Text(
                assessment.name,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ),
      ],
      rows: <DataRow>[
        for (Student student in students)
          DataRow(
            cells: <DataCell>[
              DataCell(Text(student.name)),
              for (Assessment assessment in assessments)
                DataCell(
                    AssessmentScore(score: assessment.scoreMap[student] ?? -1)),
            ],
          )
      ],
    );
  }
}
