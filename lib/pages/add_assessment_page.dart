import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/assessment.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/assessment_widget.dart';

/// Page where the user can add assessments
/// Takes in a [callback] and a list of [Student]s and displays assement
class AddAssessmentPage extends StatefulWidget {
  /// The callback for when the assessment is saved
  final Function(Assessment)? callback;

  /// The list of students to assess
  final List<Student> students;

  /// Page where the user can add assessments
  /// Takes in a [callback] and a list of [Student]s and displays assement
  const AddAssessmentPage({Key? key, this.callback, required this.students})
      : super(key: key);

  @override
  State<AddAssessmentPage> createState() => _AddAssessmentPageState();
}

class _AddAssessmentPageState extends State<AddAssessmentPage> {
  /// Controller for name text field
  final TextEditingController _controller = TextEditingController();

  /// The map part of the assessment
  late Map<Student, int> _classAssessment;

  @override
  void initState() {
    _classAssessment = {for (var student in widget.students) student: -1};
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
        itemCount: widget.students.length + 1,
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
            student: widget.students[index - 1],
            score: _classAssessment[widget.students[index - 1]] ?? -1,
            callback: (assessment) {
              // first value is [Student]
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