import 'package:flutter/material.dart';
import '../../data/model/feedback.dart';

class FeedbackPage extends StatelessWidget {
  final Function(FeedbackType) onFeedbackSubmitted;

  const FeedbackPage({super.key, required this.onFeedbackSubmitted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onFeedbackSubmitted(FeedbackType.tooEarly),
              child: const Text("まだ早いよ"),
            ),
            ElevatedButton(
              onPressed: () => onFeedbackSubmitted(FeedbackType.goodTiming),
              child: const Text("ありがとう"),
            ),
            ElevatedButton(
              onPressed: () => onFeedbackSubmitted(FeedbackType.tooLate),
              child: const Text("なんでいまさら"),
            ),
          ],
        ),
      ),
    );
  }
}
