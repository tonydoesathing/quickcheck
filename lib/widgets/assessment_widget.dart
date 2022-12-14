import 'package:flutter/material.dart';
import 'package:quickcheck/data/model/group.dart';
import 'package:quickcheck/data/model/student.dart';
import 'package:quickcheck/widgets/assessment_score.dart';

/// Assessment for a single assessee
/// Takes in the [Student] in question, a [score], and a [callback] for when a score button is pressed
/// Pass in -1 if has no score
class AssessmentWidget extends StatelessWidget {
  /// The assessee being represented
  final dynamic assessee;

  /// The assessee's score in the assessment
  final int score;

  /// The callback for when a score button is pressed
  final Function(List)? callback;
  const AssessmentWidget(
      {Key? key, required this.assessee, required this.score, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assessee == 1) {
      return const SizedBox(height: 40);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (assessee is Student)
          const SizedBox(
            width: 20,
          ),
        Expanded(
          child: Text(assessee.name ?? "NO NAME",
              overflow: TextOverflow.clip,
              style: (assessee is Group)
                  ? Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold)
                  : (assessee.groups == null || assessee.groups!.isEmpty)
                      ? Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontStyle: FontStyle.italic)
                      : null),
        ),
        Row(
          children: [
            for (int i = 4; i >= 0; i--)
              InkWell(
                onTap: () => callback?.call([assessee, score == i ? -1 : i]),
                customBorder: const CircleBorder(),
                child: Opacity(
                  opacity: score == i ? 1.0 : 0.5,
                  child: AssessmentScore(score: i),
                ),
              ),
          ],
        )
      ],
    );
  }
}
