import 'package:flutter/material.dart';
import '../controller/note_controller.dart';
import '../data/models/category_models.dart';
import '../data/models/note_models.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final controller = NoteController();
  List<Note> notes = [];
  List<Category> categories = [];
  int? selectedCategoryId;

  Future<void> loadCategories() async {
    final loadedCategories = await controller.getCategories();
    if (!mounted) return;

    setState(() {
      categories = loadedCategories;
      if (selectedCategoryId != null &&
          !categories.any((c) => c.id == selectedCategoryId)) {
        selectedCategoryId = null;
      }
    });
  }

  Future<void> loadNotes() async {
    final loadedNotes = await controller.getNotes(
      categoryId: selectedCategoryId,
    );
    if (!mounted) return;
    setState(() {
      notes = loadedNotes;
    });
  }

  Future<void> addCategory() async {
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
      await loadNotes();
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories().then((_) => loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sach ghi chu'),
        actions: [
          IconButton(
            onPressed: addCategory,
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Tao danh muc',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int?>(
              value: selectedCategoryId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Loc theo danh muc',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tat ca danh muc'),
                ),
                ...categories.map(
                  (category) => DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
              ],
              onChanged: (value) async {
                setState(() {
                  selectedCategoryId = value;
                });
                await loadNotes();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text('Danh muc: ${note.categoryName ?? ''}'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                    await loadCategories();
                    await loadNotes();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteDetailScreen()),
          );
          await loadCategories();
          await loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
