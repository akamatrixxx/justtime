import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  final VoidCallback onFeedbackSubmitted;

  const FeedbackPage({super.key, required this.onFeedbackSubmitted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('フィードバック')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 本来は FB内容を保存する
            onFeedbackSubmitted();
          },
          child: const Text('FBを送信する'),
        ),
      ),
    );
  }
}
