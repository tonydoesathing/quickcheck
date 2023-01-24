import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/widgets/assessment_score.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class GroupAssessmentTable extends StatefulWidget {
  final List<Assessment> assessments;
  final List<Group> groups;
  final List<Student> students;
  final List<Student> ungroupedStudents = [];
  final List groupsAndStudents = [];

  /// Callback for when a student is clicked
  final Function(Student)? onStudentClick;

  /// Callback for when a group is clicked
  final Function(Group)? onGroupClick;

  /// Callback for when a group is clicked
  final Function(Assessment)? onAssessmentClick;

  /// Create a table from a list of [students], [groups], and a list of [assessments]
  /// Also takes optional callbacks [onStudentClick], [onGroupClick], [onAssessmentClick]
  GroupAssessmentTable(
      {Key? key,
      required this.assessments,
      required this.groups,
      required this.students,
      this.onStudentClick,
      this.onGroupClick,
      this.onAssessmentClick})
      : super(key: key) {
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
  State<GroupAssessmentTable> createState() => _GroupAssessmentTableState();
}

class _GroupAssessmentTableState extends State<GroupAssessmentTable> {
  final LinkedScrollControllerGroup _horizontalControllers =
      LinkedScrollControllerGroup();
  final LinkedScrollControllerGroup _verticalControllers =
      LinkedScrollControllerGroup();
  late ScrollController _headController;
  late ScrollController _bodyControllerHorizontal;
  late ScrollController _columnController;
  late ScrollController _bodyControllerVertical;
  static const double _cellHeight = 50;
  static const double _cellWidth = 150;

  @override
  void initState() {
    // generate list to render

    _headController = _horizontalControllers.addAndGet();
    _bodyControllerHorizontal = _horizontalControllers.addAndGet();
    _columnController = _verticalControllers.addAndGet();
    _bodyControllerVertical = _verticalControllers.addAndGet();
    super.initState();
  }

  @override
  void dispose() {
    _headController.dispose();
    _bodyControllerHorizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assessments.isNotEmpty) {
      return Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: _cellHeight),
            child: Row(
              children: [
                const TableCell.legend(width: _cellWidth, height: _cellHeight),
                Expanded(
                    child: Scrollbar(
                  controller: _headController,
                  child: ListView.builder(
                      itemExtent: _cellWidth,
                      controller: _headController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.assessments.length,
                      itemBuilder: ((context, index) {
                        return const TableCell.stickyRow(
                            width: _cellWidth, height: _cellHeight);
                      })),
                ))
              ],
            ),
          ),
          Expanded(
              child: Row(children: [
            SizedBox(
              width: _cellWidth,
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                    controller: _columnController,
                    itemCount: widget.groupsAndStudents.length,
                    itemBuilder: ((context, index) {
                      return const TableCell.stickyColumn(
                          width: _cellWidth, height: _cellHeight);
                    })),
              ),
            ),
            Expanded(
                child: Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                controller: _bodyControllerVertical,
                child: SizedBox(
                  height: _cellHeight * widget.groupsAndStudents.length,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemExtent: _cellWidth,
                      controller: _bodyControllerHorizontal,
                      itemCount: widget.assessments.length,
                      itemBuilder: ((context, index) {
                        return Column(children: [
                          for (int i = 0;
                              i < widget.groupsAndStudents.length;
                              i++)
                            TableCell.content(
                              width: _cellWidth,
                              height: _cellHeight,
                              widget: Text("meow"),
                            )
                        ]);
                      })),
                ),
              ),
            ))
          ]))
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
      child: ListView.builder(
        itemCount: widget.ungroupedStudents.isNotEmpty
            ? widget.groupsAndStudents.length +
                (widget.groupsAndStudents.isNotEmpty ? 1 : 0) +
                1 +
                widget.ungroupedStudents.length
            // groups and students + blank row (if needed) + ungrouped title + ungrouped students
            : widget.groupsAndStudents.length,
        itemBuilder: (context, index) {
          if (index < widget.groupsAndStudents.length) {
            var element = widget.groupsAndStudents[index];
            if (element is Group) {
              return SizedBox(
                height: 50,
                width: 140,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => widget.onGroupClick?.call(element),
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
                        onPressed: () => widget.onStudentClick?.call(element),
                        child: Text(element.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.fade)),
                  ))
                ]),
              );
            }
          }

          // return the empty row
          if (index == widget.groupsAndStudents.length &&
              widget.groupsAndStudents.isNotEmpty) {
            return SizedBox(
              height: 50,
              width: 140,
            );
          }
          // return the Ungrouped title
          if (index ==
              widget.groupsAndStudents.length +
                  (widget.groupsAndStudents.isNotEmpty ? 1 : 0)) {
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
                    onPressed: () => widget.onStudentClick?.call(
                        widget.ungroupedStudents[index -
                            widget.groupsAndStudents.length -
                            1 -
                            (widget.groupsAndStudents.isNotEmpty ? 1 : 0)]),
                    child: Text(
                        widget
                            .ungroupedStudents[index -
                                widget.groupsAndStudents.length -
                                1 -
                                (widget.groupsAndStudents.isNotEmpty ? 1 : 0)]
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

// class GroupAssessmentTable extends StatelessWidget {
//   final List<Assessment> assessments;
//   final List<Group> groups;
//   final List<Student> students;
//   final List<Student> ungroupedStudents = [];
//   final List groupsAndStudents = [];

//   /// Callback for when a student is clicked
//   final Function(Student)? onStudentClick;

//   /// Callback for when a group is clicked
//   final Function(Group)? onGroupClick;

//   /// Callback for when a group is clicked
//   final Function(Assessment)? onAssessmentClick;

//   /// Create a table from a list of [students], [groups], and a list of [assessments]
//   /// Also takes optional callbacks [onStudentClick], [onGroupClick], [onAssessmentClick]
//   GroupAssessmentTable(
//       {Key? key,
//       required this.assessments,
//       required this.groups,
//       required this.students,
//       this.onStudentClick,
//       this.onGroupClick,
//       this.onAssessmentClick})
//       : super(key: key) {
//     // generate list to render
//     for (Group group in groups) {
//       groupsAndStudents.add(group);
//       for (Student student in group.members) {
//         groupsAndStudents.add(student);
//       }
//     }
//     // get ungrouped students
//     for (Student student in students) {
//       if (student.groups == null || student.groups!.isEmpty) {
//         ungroupedStudents.add(student);
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     if (assessments.isNotEmpty) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
//         child: StickyHeadersTable(
//           columnsLength: assessments.length,
//           rowsLength: ungroupedStudents.isNotEmpty
//               ? groupsAndStudents.length +
//                   (groupsAndStudents.isNotEmpty ? 1 : 0) +
//                   1 +
//                   ungroupedStudents.length
//               // groups and students + blank row (if needed) + ungrouped title + ungrouped students
//               : groupsAndStudents.length,
//           cellDimensions: const CellDimensions.fixed(
//             contentCellWidth: 140.0,
//             contentCellHeight: 50.0,
//             stickyLegendWidth: 140.0,
//             stickyLegendHeight: 50.0,
//           ),
//           columnsTitleBuilder: (columnIndex) {
//             return TableCell.stickyColumn(
//                 widget: Expanded(
//               child: Center(
//                 child: TextButton(
//                   onPressed: () =>
//                       onAssessmentClick?.call(assessments[columnIndex]),
//                   child: Text(
//                     assessments[columnIndex].name,
//                     style: Theme.of(context).textTheme.titleMedium,
//                     overflow: TextOverflow.fade,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ));
//           },
//           rowsTitleBuilder: (rowIndex) {
//             // if there aren't ungrouped
//             if (rowIndex < groupsAndStudents.length) {
//               var element = groupsAndStudents[rowIndex];
//               if (element is Group) {
//                 return TableCell.stickyRow(
//                     widget: Expanded(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: TextButton(
//                       onPressed: () => onGroupClick?.call(element),
//                       child: Text(
//                         element.name,
//                         style: Theme.of(context)
//                             .textTheme
//                             .titleMedium!
//                             .copyWith(fontWeight: FontWeight.bold),
//                         overflow: TextOverflow.fade,
//                       ),
//                     ),
//                   ),
//                 ));
//               } else if (element is Student) {
//                 return TableCell.stickyRow(
//                     widget: Expanded(
//                   child: Row(children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                         child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextButton(
//                           onPressed: () => onStudentClick?.call(element),
//                           child: Text(element.name,
//                               style: Theme.of(context).textTheme.bodyMedium,
//                               overflow: TextOverflow.fade)),
//                     ))
//                   ]),
//                 ));
//               }
//             }

//             // return the empty row
//             if (rowIndex == groupsAndStudents.length &&
//                 groupsAndStudents.isNotEmpty) {
//               return const TableCell.stickyRow(
//                 colorHorizontalBorder: Colors.transparent,
//                 colorVerticalBorder: Colors.transparent,
//               );
//             }
//             // return the Ungrouped title
//             if (rowIndex ==
//                 groupsAndStudents.length +
//                     (groupsAndStudents.isNotEmpty ? 1 : 0)) {
//               return TableCell.stickyRow(
//                   widget: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Ungrouped",
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.fade),
//               ));
//             }
// // return ungrouped students
//             return TableCell.stickyRow(
//                 widget: Expanded(
//               child: Row(children: [
//                 const SizedBox(
//                   width: 20,
//                 ),
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: TextButton(
//                       onPressed: () => onStudentClick?.call(ungroupedStudents[
//                           rowIndex -
//                               groupsAndStudents.length -
//                               1 -
//                               (groupsAndStudents.isNotEmpty ? 1 : 0)]),
//                       child: Text(
//                           ungroupedStudents[rowIndex -
//                                   groupsAndStudents.length -
//                                   1 -
//                                   (groupsAndStudents.isNotEmpty ? 1 : 0)]
//                               .name,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                           overflow: TextOverflow.fade),
//                     ),
//                   ),
//                 )
//               ]),
//             ));
//           },
//           contentCellBuilder: (columnIndex, rowIndex) {
//             //the grouped
//             if (rowIndex < groupsAndStudents.length) {
//               return TableCell.content(
//                 widget: Expanded(
//                   child: Center(
//                     child: AssessmentScore(
//                         score: assessments[columnIndex]
//                                 .scoreMap[groupsAndStudents[rowIndex]] ??
//                             -1),
//                   ),
//                 ),
//               );
//             }
//             // the empty row
//             if (rowIndex == groupsAndStudents.length &&
//                 groupsAndStudents.isNotEmpty) {
//               return const TableCell.content(
//                 colorHorizontalBorder: Colors.transparent,
//                 colorVerticalBorder: Colors.transparent,
//               );
//             }
//             // the ungrouped title
//             if (rowIndex ==
//                 groupsAndStudents.length +
//                     (groupsAndStudents.isNotEmpty ? 1 : 0)) {
//               return const TableCell.content();
//             }
//             // the ungrouped
//             return TableCell.content(
//               widget: Expanded(
//                 child: Center(
//                   child: AssessmentScore(
//                       score: assessments[columnIndex].scoreMap[
//                               ungroupedStudents[rowIndex -
//                                   groupsAndStudents.length -
//                                   1 -
//                                   (groupsAndStudents.isNotEmpty ? 1 : 0)]] ??
//                           -1),
//                 ),
//               ),
//             );
//           },
//           legendCell: const TableCell.legend(),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
//       child: ListView.builder(
//         itemCount: ungroupedStudents.isNotEmpty
//             ? groupsAndStudents.length +
//                 (groupsAndStudents.isNotEmpty ? 1 : 0) +
//                 1 +
//                 ungroupedStudents.length
//             // groups and students + blank row (if needed) + ungrouped title + ungrouped students
//             : groupsAndStudents.length,
//         itemBuilder: (context, index) {
//           if (index < groupsAndStudents.length) {
//             var element = groupsAndStudents[index];
//             if (element is Group) {
//               return SizedBox(
//                 height: 50,
//                 width: 140,
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: TextButton(
//                     onPressed: () => onGroupClick?.call(element),
//                     child: Text(
//                       element.name,
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium!
//                           .copyWith(fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.fade,
//                     ),
//                   ),
//                 ),
//               );
//             } else if (element is Student) {
//               return SizedBox(
//                 height: 50,
//                 width: 140,
//                 child: Row(children: [
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   Expanded(
//                       child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: TextButton(
//                         onPressed: () => onStudentClick?.call(element),
//                         child: Text(element.name,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                             overflow: TextOverflow.fade)),
//                   ))
//                 ]),
//               );
//             }
//           }

//           // return the empty row
//           if (index == groupsAndStudents.length &&
//               groupsAndStudents.isNotEmpty) {
//             return SizedBox(
//               height: 50,
//               width: 140,
//             );
//           }
//           // return the Ungrouped title
//           if (index ==
//               groupsAndStudents.length +
//                   (groupsAndStudents.isNotEmpty ? 1 : 0)) {
//             return SizedBox(
//               height: 50,
//               width: 140,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Ungrouped",
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium!
//                         .copyWith(fontWeight: FontWeight.bold),
//                     overflow: TextOverflow.fade),
//               ),
//             );
//           }

//           // return ungrouped students
//           return SizedBox(
//             height: 50,
//             width: 140,
//             child: Row(children: [
//               const SizedBox(
//                 width: 20,
//               ),
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: TextButton(
//                     onPressed: () => onStudentClick?.call(ungroupedStudents[
//                         index -
//                             groupsAndStudents.length -
//                             1 -
//                             (groupsAndStudents.isNotEmpty ? 1 : 0)]),
//                     child: Text(
//                         ungroupedStudents[index -
//                                 groupsAndStudents.length -
//                                 1 -
//                                 (groupsAndStudents.isNotEmpty ? 1 : 0)]
//                             .name,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                         overflow: TextOverflow.fade),
//                   ),
//                 ),
//               )
//             ]),
//           );
//         },
//       ),
//     );
//   }
// }

class TableCell extends StatelessWidget {
  const TableCell.content(
      {this.widget,
      Key? key,
      this.onTap,
      required this.width,
      required this.height,
      this.colorVerticalBorderRight = Colors.transparent,
      this.colorVerticalBorderLeft = Colors.transparent,
      this.colorHorizontalBorderTop,
      this.colorHorizontalBorderBottom})
      : super(key: key);

  const TableCell.legend(
      {this.widget,
      Key? key,
      this.onTap,
      required this.width,
      required this.height,
      this.colorVerticalBorderRight,
      this.colorVerticalBorderLeft,
      this.colorHorizontalBorderTop,
      this.colorHorizontalBorderBottom})
      : super(key: key);

  const TableCell.stickyRow(
      {this.widget,
      Key? key,
      this.onTap,
      required this.width,
      required this.height,
      this.colorVerticalBorderRight,
      this.colorVerticalBorderLeft,
      this.colorHorizontalBorderTop,
      this.colorHorizontalBorderBottom})
      : super(key: key);

  const TableCell.stickyColumn(
      {this.widget,
      Key? key,
      this.onTap,
      required this.width,
      required this.height,
      this.colorVerticalBorderRight,
      this.colorVerticalBorderLeft = Colors.transparent,
      this.colorHorizontalBorderTop,
      this.colorHorizontalBorderBottom})
      : super(key: key);

  final Function()? onTap;

  final Widget? widget;

  final Color? colorHorizontalBorderTop;
  final Color? colorHorizontalBorderBottom;
  final Color? colorVerticalBorderLeft;
  final Color? colorVerticalBorderRight;

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: colorVerticalBorderLeft == Colors.transparent
                  ? BorderSide.none
                  : BorderSide(
                      color: colorVerticalBorderLeft ??
                          Theme.of(context).dividerColor),
              right: colorVerticalBorderRight == Colors.transparent
                  ? BorderSide.none
                  : BorderSide(
                      color: colorVerticalBorderRight ??
                          Theme.of(context).dividerColor),
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
                color: colorHorizontalBorderBottom ??
                    Theme.of(context).dividerColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
