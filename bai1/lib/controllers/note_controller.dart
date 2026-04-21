import '../data/models/note_model.dart';
import '../data/repository/note_repository.dart';

class NoteController {
  final NoteRepository _repository = NoteRepository();

  Future<List<Note>> getNotes() async {
    return _repository.getAll();
  }

  Future<void> addNote(Note note) async {
    await _repository.insert(note);
  }

  Future<void> updateNote(Note note) async {
    await _repository.update(note);
  }

  Future<void> deleteNote(int id) async {
    await _repository.delete(id);
  }
}

