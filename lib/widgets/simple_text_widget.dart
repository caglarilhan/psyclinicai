import 'package:flutter/material.dart';

class SimpleTextWidget extends StatelessWidget {
  final String text;
  const SimpleTextWidget({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
