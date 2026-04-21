import '../models/category.dart';
import '../models/note.dart';
import '../service/app_database.dart';

class NotesRepository {
  NotesRepository({AppDatabase? database}) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Category>> getCategories() {
    return _database.getCategories();
  }

  Future<int> addCategory(String name) {
    return _database.insertCategory(Category(name: name));
  }

  Future<List<Note>> getNotes({int? categoryId}) {
    return _database.getNotes(categoryId: categoryId);
  }

  Future<int> addNote({
    required String title,
    required String content,
    required int categoryId,
  }) {
    return _database.insertNote(
      Note(
        title: title,
        content: content,
        categoryId: categoryId,
      ),
    );
  }
}

