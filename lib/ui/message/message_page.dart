import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  final String message;

  const MessagePage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message, style: const TextStyle(fontSize: 24))),
    );
  }
}
