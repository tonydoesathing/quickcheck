import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/assessment_widget.dart';

/// Page where the user can add assessments
/// Takes in a [callback] and a list of [Student]s and displays assement
class AddAssessmentPage extends StatefulWidget {
  /// The callback for when the assessment is saved
  final Function(Assessment)? callback;

  /// The list of groups to assess
  final List<Group> groups;

  /// The list of studetns
  final List<Student> students;

  /// Page where the user can add assessments
  /// Takes in a [callback] and a list of [Student]s and displays assement
  const AddAssessmentPage(
      {Key? key, this.callback, required this.groups, required this.students})
      : super(key: key);

  @override
  State<AddAssessmentPage> createState() => _AddAssessmentPageState();
}

class _AddAssessmentPageState extends State<AddAssessmentPage> {
  /// Controller for name text field
  final TextEditingController _controller = TextEditingController();

  /// The map part of the assessment
  final Map<dynamic, int> _classAssessment = {};

  /// Lookup arrays of members
  final List<dynamic> groupedAssessees = [];
  final List<Student> ungroupedAssessees = [];

  @override
  void initState() {
    // add grouped students to groupedAssessees
    for (Group group in widget.groups) {
      _classAssessment[group] = -1;
      groupedAssessees.add(group);
      for (Student student in group.members) {
        _classAssessment[student] = -1;
        groupedAssessees.add(student);
      }
    }
    // add ungrouped students to assessees
    for (Student student in widget.students) {
      if (student.groups == null || student.groups!.isEmpty) {
        _classAssessment[student] = -1;
        ungroupedAssessees.add(student);
      }
    }
    super.initState();
  }

  /// Returns the month/day/year
  String _getDateString() {
    DateTime date = DateTime.now();
    return '${date.month}/${date.day}/${date.year}';
  }

  /// submit the assessment
  Future<void> _submit() async {
    Navigator.pop(context);
    widget.callback?.call(Assessment(
        name: _controller.text.isEmpty ? _getDateString() : _controller.text,
        scoreMap: _classAssessment));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assessment"),
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: ListView.builder(
        itemCount: 1 +
            groupedAssessees.length +
            1 +
            ungroupedAssessees
                .length, // textfield, grouped assessees, ungrouped title, ungrouped students
        padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0.0),
        itemBuilder: (context, index) {
          // render name textbox first
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: "Name (optional)"),
              ),
            );
          }

          // render grouped assessees
          if (index <= groupedAssessees.length) {
            return Padding(
              padding: EdgeInsets.only(
                  top: (groupedAssessees[index - 1] is Group && index != 1)
                      ? 20
                      : 0, // add extra padding between groups
                  bottom: (ungroupedAssessees.isEmpty &&
                          index == groupedAssessees.length)
                      ? 20
                      : 0), // add extra padding at end
              child: AssessmentWidget(
                assessee: groupedAssessees[index - 1],
                score: _classAssessment[groupedAssessees[index - 1]] ?? -1,
                callback: (assessment) {
                  // first value is [Student] or [Group]
                  // second value is the score
                  setState(() {
                    var element = assessment[0];
                    int score = assessment[1];
                    if (element is Group) {
                      for (Student student in element.members) {
                        _classAssessment[student] = score;
                      }
                    }
                    _classAssessment[element] = score;
                  });
                },
              ),
            );
          }

          // render ungrouped title
          if (index == groupedAssessees.length + 1 &&
              ungroupedAssessees.isNotEmpty) {
            return Container(
                padding: const EdgeInsets.fromLTRB(0, 45, 0, 20),
                child: Text(
                  'Ungrouped Students',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ));
          }
          // render ungrouped
          if (index > groupedAssessees.length + 1) {
            int idx = index - (groupedAssessees.length + 2);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: (index ==
                          1 +
                              groupedAssessees.length +
                              1 +
                              ungroupedAssessees.length -
                              1)
                      ? 20.0
                      : 0), // add some space at the bottom
              child: AssessmentWidget(
                assessee: ungroupedAssessees[idx],
                score: _classAssessment[ungroupedAssessees[idx]] ?? -1,
                callback: (assessment) {
                  // first value is [Student] or [Group]
                  // second value is the score
                  setState(() {
                    var element = assessment[0];
                    int score = assessment[1];
                    _classAssessment[element] = score;
                  });
                },
              ),
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: BottomAppBar(
            child: Container(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                          onPrimary: Theme.of(context).colorScheme.onPrimary,
                          primary: Theme.of(context).colorScheme.primary)
                      .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async => await _submit(),
                  icon: const Icon(Icons.save),
                  label: const Text("Save")),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                    )),
              )
            ],
          ),
        )),
      ),
    );
  }
}
