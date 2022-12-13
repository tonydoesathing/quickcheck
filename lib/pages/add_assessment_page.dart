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

  /// A lookup array of members
  final List<dynamic> assessees = [];

  @override
  void initState() {
    for (Group group in widget.groups) {
      _classAssessment[group] = -1;
      assessees.add(group);
      for (Student student in group.members) {
        _classAssessment[student] = -1;
        assessees.add(student);
      }
    }
    for (Student student in widget.students) {
      if (student.groups == null || student.groups!.isEmpty) {
        assessees.add(student);
      }
    }
    super.initState();
  }

  /// Returns the month/day/year
  String _getDateString() {
    DateTime date = DateTime.now();
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assessment"),
      ),
      body: ListView.builder(
        itemCount: assessees.length + 1,
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
          // otherwise render assessment widget
          return AssessmentWidget(
            assessee: assessees[index - 1],
            score: _classAssessment[assessees[index - 1]] ?? -1,
            callback: (assessment) {
              // first value is [Student] or [Group]
              // second value is the score
              setState(() {
                _classAssessment[assessment[0]] = assessment[1];
              });
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.callback?.call(Assessment(
                      name: _controller.text.isEmpty
                          ? _getDateString()
                          : _controller.text,
                      scoreMap: _classAssessment));
                },
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
    );
  }
}
