import 'package:flutter/material.dart';

class HelloBox extends StatelessWidget {
  const HelloBox({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text("Hello from FSM"),
    );
  }
}
