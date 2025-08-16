import 'package:flutter/material.dart';

class MoodEntryUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mood Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(keyboardType: TextInputType.text, decoration: InputDecoration(labelText: 'Enter your mood')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: Text('Save Mood')),
          ],
        ),
      ),
    );
  }
}
