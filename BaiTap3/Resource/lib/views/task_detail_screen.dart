import 'package:flutter/material.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: const Center(
        child: Text('Task detail is not used in this assignment.'),
      ),
    );
  }
}
