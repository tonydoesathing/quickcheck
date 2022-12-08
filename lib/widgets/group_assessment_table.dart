import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/widgets/assessment_score.dart';

/// A table that displays students on the y-axis and assignments on the top column
/// Student names are the first column, and each column after that is their score for the associated assessment,
/// with the assessment name at the top
class GroupAssessmentTable extends StatelessWidget {
  final List<Assessment> assessments;
  final List<Group> groups;

  /// Create a table from a list of [students] and a list of [assessments]
  const GroupAssessmentTable(
      {Key? key, required this.assessments, required this.groups})
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
        for (Group group in groups) ...[
          DataRow(
            cells: <DataCell>[
              DataCell(Text(group.name,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold))),
              for (Assessment assessment in assessments)
                DataCell(
                    AssessmentScore(score: assessment.scoreMap[group] ?? -1)),
            ],
          ),
          for (Student student in group.members)
            DataRow(
              cells: <DataCell>[
                DataCell(Text(student.name, textAlign: TextAlign.right)),
                for (Assessment assessment in assessments)
                  DataCell(AssessmentScore(
                      score: assessment.scoreMap[student] ?? -1)),
              ],
            )
        ]
      ],
    );
  }
}
