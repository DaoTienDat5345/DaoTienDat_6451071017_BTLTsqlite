import 'package:sqflite/sqflite.dart';

import '../models/note_model.dart';
import '../services/database_service.dart';

class NoteRepository {
  Future<int> insert(Note note) async {
    final Database db = await DatabaseService.database;
    return db.insert(DatabaseService.notesTable, note.toMap());
  }

  Future<List<Note>> getAll() async {
    final Database db = await DatabaseService.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseService.notesTable,
      orderBy: 'id DESC',
    );
    return result.map(Note.fromMap).toList();
  }

  Future<int> update(Note note) async {
    final Database db = await DatabaseService.database;
    return db.update(
      DatabaseService.notesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final Database db = await DatabaseService.database;
    return db.delete(
      DatabaseService.notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

