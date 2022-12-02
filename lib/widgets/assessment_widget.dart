import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/assessment_score.dart';

/// Assessment for a single student
/// Takes in the [Student] in question, a [score], and a [callback] for when a score button is pressed
/// Pass in -1 if has no score
class AssessmentWidget extends StatelessWidget {
  /// The student being represented
  final Student student;

  /// The student's score in the assessment
  final int score;

  /// The callback for when a score button is pressed
  final Function(List)? callback;
  const AssessmentWidget(
      {Key? key, required this.student, required this.score, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(student.name),
      title: Row(
        children: [
          for (int i = 4; i >= 0; i--)
            InkWell(
              onTap: () => callback?.call([student, score == i ? -1 : i]),
              customBorder: const CircleBorder(),
              child: Opacity(
                opacity: score == i ? 1.0 : 0.5,
                child: AssessmentScore(score: i),
              ),
            ),
        ],
      ),
    );
  }
}
