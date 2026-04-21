import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import '../../data/models/note_model.dart';
import '../../utils/confirm_dialog.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteController _controller = NoteController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note?.title ?? '';
    _contentController.text = widget.note?.content ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and content.')),
      );
      return;
    }

    final Note note = Note(
      id: widget.note?.id,
      title: title,
      content: content,
    );

    if (_isEdit) {
      await _controller.updateNote(note);
    } else {
      await _controller.addNote(note);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteNote() async {
    final int? noteId = widget.note?.id;
    if (noteId == null) return;

    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete note',
      content: 'Are you sure you want to delete this note?',
    );

    if (!confirmed) return;

    await _controller.deleteNote(noteId);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Note' : 'Add Note'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _deleteNote,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveNote,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

