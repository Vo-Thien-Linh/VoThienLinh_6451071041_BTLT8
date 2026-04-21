import 'package:flutter/material.dart';
import '../controller/note_controller.dart';
import '../data/models/note_models.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final controller = NoteController();
  List<Note> notes = [];

  Future<void> loadNotes() async {
    final loadedNotes = await controller.getNotes();
    if (!mounted) return;
    setState(() {
      notes = loadedNotes;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes - 6451071041")),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
              );
              await loadNotes();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteDetailScreen()),
          );
          await loadNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
