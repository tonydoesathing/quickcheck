import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/widgets/assessment_score.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

/// A table that displays students on the y-axis and assignments on the top column
/// Student names are the first column, and each column after that is their score for the associated assessment,
/// with the assessment name at the top
class GroupAssessmentTable extends StatelessWidget {
  final List<Assessment> assessments;
  final List<Group> groups;
  final List<Student> students;
  List<Student> ungroupedStudents = [];
  List groupsAndStudents = [];

  /// Callback for when a student is clicked
  final Function(Student)? onStudentClick;

  /// Callback for when a group is clicked
  final Function(Group)? onGroupClick;

  /// Create a table from a list of [students] and a list of [assessments]
  GroupAssessmentTable(
      {Key? key,
      required this.assessments,
      required this.groups,
      required this.students,
      this.onStudentClick,
      this.onGroupClick})
      : super(key: key) {
    // generate list to render
    for (Group group in groups) {
      groupsAndStudents.add(group);
      for (Student student in group.members) {
        groupsAndStudents.add(student);
      }
    }
    // get ungrouped students
    for (Student student in students) {
      if (student.groups == null || student.groups!.isEmpty) {
        ungroupedStudents.add(student);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (assessments.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
        child: StickyHeadersTable(
          columnsLength: assessments.length,
          rowsLength: ungroupedStudents.isNotEmpty
              ? groupsAndStudents.length +
                  (groupsAndStudents.isNotEmpty ? 1 : 0) +
                  1 +
                  ungroupedStudents.length
              // groups and students + blank row (if needed) + ungrouped title + ungrouped students
              : groupsAndStudents.length,
          cellDimensions: const CellDimensions.fixed(
            contentCellWidth: 140.0,
            contentCellHeight: 50.0,
            stickyLegendWidth: 140.0,
            stickyLegendHeight: 50.0,
          ),
          columnsTitleBuilder: (columnIndex) {
            return TableCell.stickyColumn(
                widget: Expanded(
              child: Center(
                child: Text(
                  assessments[columnIndex].name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                ),
              ),
            ));
          },
          rowsTitleBuilder: (rowIndex) {
            // if there aren't ungrouped
            if (rowIndex < groupsAndStudents.length) {
              var element = groupsAndStudents[rowIndex];
              if (element is Group) {
                return TableCell.stickyRow(
                    widget: Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => onGroupClick?.call(element),
                      child: Text(
                        element.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ));
              } else if (element is Student) {
                return TableCell.stickyRow(
                    widget: Expanded(
                  child: Row(children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () => onStudentClick?.call(element),
                          child: Text(element.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.fade)),
                    ))
                  ]),
                ));
              }
            }

            // return the empty row
            if (rowIndex == groupsAndStudents.length &&
                groupsAndStudents.isNotEmpty) {
              return const TableCell.stickyRow(
                colorHorizontalBorder: Colors.transparent,
                colorVerticalBorder: Colors.transparent,
              );
            }
            // return the Ungrouped title
            if (rowIndex ==
                groupsAndStudents.length +
                    (groupsAndStudents.isNotEmpty ? 1 : 0)) {
              return TableCell.stickyRow(
                  widget: Align(
                alignment: Alignment.centerLeft,
                child: Text("Ungrouped",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.fade),
              ));
            }
// return ungrouped students
            return TableCell.stickyRow(
                widget: Expanded(
              child: Row(children: [
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => onStudentClick?.call(ungroupedStudents[
                          rowIndex -
                              groupsAndStudents.length -
                              1 -
                              (groupsAndStudents.isNotEmpty ? 1 : 0)]),
                      child: Text(
                          ungroupedStudents[rowIndex -
                                  groupsAndStudents.length -
                                  1 -
                                  (groupsAndStudents.isNotEmpty ? 1 : 0)]
                              .name,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.fade),
                    ),
                  ),
                )
              ]),
            ));
          },
          contentCellBuilder: (columnIndex, rowIndex) {
            //the grouped
            if (rowIndex < groupsAndStudents.length) {
              return TableCell.content(
                widget: Expanded(
                  child: Center(
                    child: AssessmentScore(
                        score: assessments[columnIndex]
                                .scoreMap[groupsAndStudents[rowIndex]] ??
                            -1),
                  ),
                ),
              );
            }
            // the empty row
            if (rowIndex == groupsAndStudents.length &&
                groupsAndStudents.isNotEmpty) {
              return const TableCell.content(
                colorHorizontalBorder: Colors.transparent,
                colorVerticalBorder: Colors.transparent,
              );
            }
            // the ungrouped title
            if (rowIndex ==
                groupsAndStudents.length +
                    (groupsAndStudents.isNotEmpty ? 1 : 0)) {
              return const TableCell.content();
            }
            // the ungrouped
            return TableCell.content(
              widget: Expanded(
                child: Center(
                  child: AssessmentScore(
                      score: assessments[columnIndex].scoreMap[
                              ungroupedStudents[rowIndex -
                                  groupsAndStudents.length -
                                  1 -
                                  (groupsAndStudents.isNotEmpty ? 1 : 0)]] ??
                          -1),
                ),
              ),
            );
          },
          legendCell: const TableCell.legend(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
      child: ListView.builder(
        itemCount: ungroupedStudents.isNotEmpty
            ? groupsAndStudents.length +
                (groupsAndStudents.isNotEmpty ? 1 : 0) +
                1 +
                ungroupedStudents.length
            // groups and students + blank row (if needed) + ungrouped title + ungrouped students
            : groupsAndStudents.length,
        itemBuilder: (context, index) {
          if (index < groupsAndStudents.length) {
            var element = groupsAndStudents[index];
            if (element is Group) {
              return SizedBox(
                height: 50,
                width: 140,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => onGroupClick?.call(element),
                    child: Text(
                      element.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              );
            } else if (element is Student) {
              return SizedBox(
                height: 50,
                width: 140,
                child: Row(children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: () => onStudentClick?.call(element),
                        child: Text(element.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.fade)),
                  ))
                ]),
              );
            }
          }

          // return the empty row
          if (index == groupsAndStudents.length &&
              groupsAndStudents.isNotEmpty) {
            return SizedBox(
              height: 50,
              width: 140,
            );
          }
          // return the Ungrouped title
          if (index ==
              groupsAndStudents.length +
                  (groupsAndStudents.isNotEmpty ? 1 : 0)) {
            return SizedBox(
              height: 50,
              width: 140,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Ungrouped",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.fade),
              ),
            );
          }

          // return ungrouped students
          return SizedBox(
            height: 50,
            width: 140,
            child: Row(children: [
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => onStudentClick?.call(ungroupedStudents[
                        index -
                            groupsAndStudents.length -
                            1 -
                            (groupsAndStudents.isNotEmpty ? 1 : 0)]),
                    child: Text(
                        ungroupedStudents[index -
                                groupsAndStudents.length -
                                1 -
                                (groupsAndStudents.isNotEmpty ? 1 : 0)]
                            .name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.fade),
                  ),
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}

class TableCell extends StatelessWidget {
  const TableCell.content({
    this.widget,
    Key? key,
    this.onTap,
    this.colorHorizontalBorder = Colors.transparent,
    this.colorVerticalBorder,
  }) : super(key: key);

  const TableCell.legend({
    this.widget,
    Key? key,
    this.onTap,
    this.colorHorizontalBorder,
    this.colorVerticalBorder,
  }) : super(key: key);

  const TableCell.stickyRow({
    this.widget,
    Key? key,
    this.onTap,
    this.colorHorizontalBorder,
    this.colorVerticalBorder,
  }) : super(key: key);

  const TableCell.stickyColumn({
    this.widget,
    Key? key,
    this.onTap,
    this.colorVerticalBorder,
    this.colorHorizontalBorder = Colors.transparent,
  }) : super(key: key);

  final Function()? onTap;

  final Widget? widget;

  final Color? colorHorizontalBorder;
  final Color? colorVerticalBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            // left: colorHorizontalBorder == null
            //     ? BorderSide.none
            //     : BorderSide(color: colorHorizontalBorder!),
            right: BorderSide(
                color: colorHorizontalBorder ?? Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: [
                  widget ?? Container(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 2,
              color: colorVerticalBorder ?? Theme.of(context).dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}
