import 'package:flutter/material.dart';
import 'package:quickcheck/widgets/quick_check_icons_icons.dart';

/// Shows a stylized icon from a [score]
class AssessmentScore extends StatelessWidget {
  /// The score to display
  final int score;

  /// Creates a stylized icon from a [score]
  const AssessmentScore({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _scoreColor()),
        child: Center(
          child: _scoreIcon(),
        ),
      ),
    );
  }

  /// Returns the appropriate background color based off the score
  Color _scoreColor() {
    switch (score) {
      case 0:
        return const Color(0xFFC8C6CA);
      case 1:
        return const Color(0xFFEA7F8E);
      case 2:
        return const Color(0xFFFECF2B);
      case 3:
        return const Color(0xFFACD918);
      case 4:
        return const Color(0xFF51CA57);
      default:
        return const Color(0x00000000);
    }
  }

  /// Returns the appropriate icon based off the score
  Widget _scoreIcon() {
    switch (score) {
      case 0:
        return const Text(
          "N/A",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      case 1:
        return const Icon(
          QuickCheckIcons.one_rating_icon,
          size: 16.0,
        );
      case 2:
        return const Icon(
          QuickCheckIcons.two_rating_icon,
          size: 20.0,
        );
      case 3:
        return const Icon(
          QuickCheckIcons.three_rating_icon,
          size: 20.0,
        );
      case 4:
        return const Icon(
          QuickCheckIcons.four_rating_icon,
          size: 20.0,
        );
      default:
        return Container();
    }
  }
}
