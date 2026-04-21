import 'package:flutter/material.dart';
import '../controller/note_controller.dart';
import '../data/models/note_models.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  NoteDetailScreen({this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final controller = NoteController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  void saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title không được để trống')),
      );
      return;
    }

    try {
      if (widget.note == null) {
        await controller.addNote(title, content);
      } else {
        await controller.updateNote(
          Note(id: widget.note!.id, title: title, content: content),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không lưu được note: $error')));
    }
  }

  void deleteNote() async {
    if (widget.note != null) {
      await controller.deleteNote(widget.note!.id!);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Note Detail - 6451071041"),
        actions: [
          if (widget.note != null)
            IconButton(icon: Icon(Icons.delete), onPressed: deleteNote),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: "Content"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveNote, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}
