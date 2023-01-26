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
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 8;

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
    _bodyControllerVertical.dispose();
    _columnController.dispose();
    super.dispose();
  }

  Widget _buildAssessmentColumnCell(int assessmentIndex, int i) {
    //the grouped
    if (i < widget.groupsAndStudents.length) {
      return TableCell.content(
        width: _cellWidth,
        height: _cellHeight,
        widget: widget.groupsAndStudents[i] is Student
            ? Expanded(
                child: Center(
                  child: AssessmentScore(
                      score: widget.assessments[assessmentIndex]
                              .scoreMap[widget.groupsAndStudents[i]] ??
                          -1),
                ),
              )
            : null,
      );
    }
    // the empty row
    if (i == widget.groupsAndStudents.length &&
        widget.groupsAndStudents.isNotEmpty) {
      return const TableCell.content(
        width: _cellWidth,
        height: _cellHeight,
        colorHorizontalBorderTop: Colors.transparent,
        colorHorizontalBorderBottom: Colors.transparent,
        colorVerticalBorderLeft: Colors.transparent,
        colorVerticalBorderRight: Colors.transparent,
      );
    }
    // the ungrouped title
    if (i ==
        widget.groupsAndStudents.length +
            (widget.groupsAndStudents.isNotEmpty ? 1 : 0)) {
      return const TableCell.content(
        width: _cellWidth,
        height: _cellHeight,
      );
    }
    // the ungrouped
    return TableCell.content(
      width: _cellWidth,
      height: _cellHeight,
      widget: Expanded(
        child: Center(
          child: AssessmentScore(
              score: widget.assessments[assessmentIndex].scoreMap[
                      widget.ungroupedStudents[i -
                          widget.groupsAndStudents.length -
                          1 -
                          (widget.groupsAndStudents.isNotEmpty ? 1 : 0)]] ??
                  -1),
        ),
      ),
    );
  }

  Widget _buildAssessmentColumn(int assessmentIndex) {
    List<Widget> children = [];
    int length = widget.ungroupedStudents.isNotEmpty
        ? widget.groupsAndStudents.length +
            (widget.groupsAndStudents.isNotEmpty ? 1 : 0) +
            1 +
            widget.ungroupedStudents.length
        // groups and students + blank row (if needed) + ungrouped title + ungrouped students
        : widget.groupsAndStudents.length;

    for (int i = 0; i < length; i++) {
      children.add(Padding(
        padding: EdgeInsets.only(
            right: assessmentIndex == widget.assessments.length - 1
                ? _horizontalPadding
                : 0),
        child: _buildAssessmentColumnCell(assessmentIndex, i),
      ));
    }

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assessments.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(
            top: _verticalPadding, bottom: _verticalPadding),
        child: Column(
          children: [
            ///////////////////////////////////////////
            //////////  Sticky Row   /////////////////
            //////////////////////////////////////////
            Container(
              constraints: const BoxConstraints(maxHeight: _cellHeight),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: _horizontalPadding),
                    child: TableCell.legend(
                        width: _cellWidth, height: _cellHeight),
                  ),
                  Expanded(
                      child: Scrollbar(
                    controller: _headController,
                    child: ListView.builder(
                        itemExtent: _cellWidth,
                        controller: _headController,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.assessments.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                right: index == widget.assessments.length - 1
                                    ? _horizontalPadding
                                    : 0),
                            child: TableCell.stickyRow(
                              width: _cellWidth,
                              height: _cellHeight,
                              widget: Expanded(
                                child: Center(
                                  child: TextButton(
                                    onPressed: () => widget.onAssessmentClick
                                        ?.call(widget.assessments[index]),
                                    child: Text(
                                      widget.assessments[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })),
                  ))
                ],
              ),
            ),
            ///////////////////////////////////////////
            //////////  Sticky Column   //////////////
            //////////////////////////////////////////
            Expanded(
                child: Row(children: [
              SizedBox(
                width: _cellWidth + _horizontalPadding,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: Padding(
                    padding: const EdgeInsets.only(left: _horizontalPadding),
                    child: ListView.builder(
                        controller: _columnController,
                        itemCount: widget.ungroupedStudents.isNotEmpty
                            ? widget.groupsAndStudents.length +
                                (widget.groupsAndStudents.isNotEmpty ? 1 : 0) +
                                1 +
                                widget.ungroupedStudents.length
                            // groups and students + blank row (if needed) + ungrouped title + ungrouped students
                            : widget.groupsAndStudents.length,
                        itemBuilder: ((context, index) {
                          // if there aren't ungrouped
                          if (index < widget.groupsAndStudents.length) {
                            var element = widget.groupsAndStudents[index];
                            if (element is Group) {
                              return TableCell.stickyColumn(
                                  width: _cellWidth,
                                  height: _cellHeight,
                                  widget: Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () =>
                                            widget.onGroupClick?.call(element),
                                        child: Text(
                                          element.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                    ),
                                  ));
                            } else if (element is Student) {
                              return TableCell.stickyColumn(
                                  width: _cellWidth,
                                  height: _cellHeight,
                                  widget: Expanded(
                                    child: Row(children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                            onPressed: () => widget
                                                .onStudentClick
                                                ?.call(element),
                                            child: Text(element.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                                overflow: TextOverflow.fade)),
                                      ))
                                    ]),
                                  ));
                            }
                          }

                          // return the empty row
                          if (index == widget.groupsAndStudents.length &&
                              widget.groupsAndStudents.isNotEmpty) {
                            return const TableCell.stickyColumn(
                              width: _cellWidth,
                              height: _cellHeight,
                              colorHorizontalBorderBottom: Colors.transparent,
                              colorHorizontalBorderTop: Colors.transparent,
                              colorVerticalBorderLeft: Colors.transparent,
                              colorVerticalBorderRight: Colors.transparent,
                            );
                          }
                          // return the Ungrouped title
                          if (index ==
                              widget.groupsAndStudents.length +
                                  (widget.groupsAndStudents.isNotEmpty
                                      ? 1
                                      : 0)) {
                            return TableCell.stickyColumn(
                                width: _cellWidth,
                                height: _cellHeight,
                                widget: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Ungrouped",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.fade),
                                ));
                          }
                          // return ungrouped students
                          return TableCell.stickyColumn(
                              width: _cellWidth,
                              height: _cellHeight,
                              widget: Expanded(
                                child: Row(children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () => widget.onStudentClick
                                            ?.call(widget.ungroupedStudents[
                                                index -
                                                    widget.groupsAndStudents
                                                        .length -
                                                    1 -
                                                    (widget.groupsAndStudents
                                                            .isNotEmpty
                                                        ? 1
                                                        : 0)]),
                                        child: Text(
                                            widget
                                                .ungroupedStudents[index -
                                                    widget.groupsAndStudents
                                                        .length -
                                                    1 -
                                                    (widget.groupsAndStudents
                                                            .isNotEmpty
                                                        ? 1
                                                        : 0)]
                                                .name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            overflow: TextOverflow.fade),
                                      ),
                                    ),
                                  )
                                ]),
                              ));
                        })),
                  ),
                ),
              ),
              //////////////////////////////////////////////
              ///////////////      content      ////////////
              //////////////////////////////////////////////
              Expanded(
                  child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  controller: _bodyControllerVertical,
                  child: SizedBox(
                    height: _cellHeight *
                        (widget.ungroupedStudents.isNotEmpty
                            ? widget.groupsAndStudents.length +
                                (widget.groupsAndStudents.isNotEmpty ? 1 : 0) +
                                1 +
                                widget.ungroupedStudents.length
                            // groups and students + blank row (if needed) + ungrouped title + ungrouped students
                            : widget.groupsAndStudents.length),
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemExtent: _cellWidth,
                        controller: _bodyControllerHorizontal,
                        itemCount: widget.assessments.length,
                        itemBuilder: ((context, index) {
                          return _buildAssessmentColumn(index);
                        })),
                  ),
                ),
              ))
            ]))
          ],
        ),
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
                width: _cellWidth,
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
                height: _cellHeight,
                width: _cellWidth,
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
            return const SizedBox(
              height: _cellHeight,
              width: _cellWidth,
            );
          }
          // return the Ungrouped title
          if (index ==
              widget.groupsAndStudents.length +
                  (widget.groupsAndStudents.isNotEmpty ? 1 : 0)) {
            return SizedBox(
              height: _cellHeight,
              width: _cellWidth,
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
            width: _cellWidth,
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
      this.colorVerticalBorderLeft = Colors.transparent,
      this.colorHorizontalBorderTop = Colors.transparent,
      this.colorHorizontalBorderBottom})
      : super(key: key);

  const TableCell.stickyRow(
      {this.widget,
      Key? key,
      this.onTap,
      required this.width,
      required this.height,
      this.colorVerticalBorderRight = Colors.transparent,
      this.colorVerticalBorderLeft,
      this.colorHorizontalBorderTop = Colors.transparent,
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
