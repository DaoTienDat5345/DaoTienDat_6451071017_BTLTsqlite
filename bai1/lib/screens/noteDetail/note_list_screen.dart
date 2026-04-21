import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../data/models/note_model.dart';
import '../../utils/confirm_dialog.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final NoteController _controller = NoteController();
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _reloadNotes();
  }

  void _reloadNotes() {
    setState(() {
      _notesFuture = _controller.getNotes();
    });
  }

  Future<void> _openNoteForm({Note? note}) async {
    final bool? changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(note: note),
      ),
    );

    if (changed == true) {
      _reloadNotes();
    }
  }

  Future<void> _deleteFromList(Note note) async {
    final int? noteId = note.id;
    if (noteId == null) return;

    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete note',
      content: 'Are you sure you want to delete "${note.title}"?',
    );

    if (!confirmed) return;

    await _controller.deleteNote(noteId);
    _reloadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notes = snapshot.data ?? <Note>[];
          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet. Tap + to add a note.'),
            );
          }

          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openNoteForm(note: note),
                trailing: IconButton(
                  onPressed: () => _deleteFromList(note),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

