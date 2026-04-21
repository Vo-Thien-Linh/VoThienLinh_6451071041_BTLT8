import 'package:flutter/material.dart';
import '../controller/note_controller.dart';
import '../data/models/category_models.dart';
import '../data/models/note_models.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final controller = NoteController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  List<Category> categories = [];
  int? selectedCategoryId;

  Future<void> loadCategories() async {
    final loadedCategories = await controller.getCategories();
    if (!mounted) return;

    setState(() {
      categories = loadedCategories;

      // Keep selected category valid after data refresh.
      if (selectedCategoryId != null &&
          !categories.any((c) => c.id == selectedCategoryId)) {
        selectedCategoryId = null;
      }

      selectedCategoryId ??= categories.isNotEmpty ? categories.first.id : null;
    });
  }

  Future<void> addCategoryFromDetail() async {
    final nameController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tao danh muc'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Ten danh muc'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Luu'),
            ),
          ],
        );
      },
    );

    final name = nameController.text.trim();
    if (result == true && name.isNotEmpty) {
      await controller.addCategory(name);
      await loadCategories();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      selectedCategoryId = widget.note!.categoryId;
    }
    loadCategories();
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

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ban can tao va chon danh muc truoc')),
      );
      return;
    }

    try {
      if (widget.note == null) {
        await controller.addNote(
          title: title,
          content: content,
          categoryId: selectedCategoryId!,
        );
      } else {
        await controller.updateNote(
          Note(
            id: widget.note!.id,
            title: title,
            content: content,
            categoryId: selectedCategoryId!,
          ),
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
      if (!mounted) return;
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
        title: const Text('Chi tiet ghi chu'),
        actions: [
          if (widget.note != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: deleteNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: categories.any((c) => c.id == selectedCategoryId)
                  ? selectedCategoryId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Chon danh muc'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: addCategoryFromDetail,
                icon: const Icon(Icons.add),
                label: const Text('Them danh muc'),
              ),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveNote, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
