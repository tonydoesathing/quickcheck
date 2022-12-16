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
  final List<Student> students;

  /// Callback for when a student is clicked
  final Function(Student)? onStudentClick;

  /// Callback for when a group is clicked
  final Function(Group)? onGroupClick;

  /// Create a table from a list of [students] and a list of [assessments]
  const GroupAssessmentTable(
      {Key? key,
      required this.assessments,
      required this.groups,
      required this.students,
      this.onStudentClick,
      this.onGroupClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 70.0),
      child: DataTable(
        columns: <DataColumn>[
          const DataColumn(
            label: Expanded(
              child: Text(
                '',
              ),
            ),
          ),
          for (Assessment assessment in assessments)
            DataColumn(
              label: Expanded(
                child: Text(
                  assessment.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
        rows: <DataRow>[
          for (Group group in groups) ...[
            DataRow(
              cells: <DataCell>[
                DataCell(TextButton(
                  onPressed: () => onGroupClick?.call(group),
                  child: Text(group.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold)),
                )),
                for (Assessment assessment in assessments)
                  DataCell(Center(
                      child: AssessmentScore(
                          score: assessment.scoreMap[group] ?? -1))),
              ],
            ),
            for (Student student in group.members)
              DataRow(
                cells: <DataCell>[
                  DataCell(Row(children: [
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                        onPressed: () => onStudentClick?.call(student),
                        child: Text(
                          student.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ))
                  ])),
                  for (Assessment assessment in assessments)
                    DataCell(Center(
                      child: AssessmentScore(
                          score: assessment.scoreMap[student] ?? -1),
                    )),
                ],
              ),
          ],
          DataRow(
            cells: <DataCell>[
              DataCell(Row(children: const [
                SizedBox(
                  width: 20,
                ),
                Text('')
              ])),
              for (Assessment assessment in assessments)
                DataCell(Center(
                  child: Container(),
                )),
            ],
          ),
          for (Student student in students)
            if (student.groups == null || student.groups!.isEmpty)
              DataRow(
                cells: <DataCell>[
                  DataCell(Row(children: [
                    const SizedBox(
                      width: 20,
                    ),
                    TextButton(
                      onPressed: () => onStudentClick?.call(student),
                      child: Text(
                        student.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    )
                  ])),
                  for (Assessment assessment in assessments)
                    DataCell(Center(
                      child: AssessmentScore(
                          score: assessment.scoreMap[student] ?? -1),
                    )),
                ],
              ),
        ],
      ),
    );
  }
}
