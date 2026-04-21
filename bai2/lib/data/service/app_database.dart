import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/note.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'bai2_notes.db';
  static const _databaseVersion = 1;

  static const categoryTable = 'categories';
  static const noteTable = 'notes';

  Database? _database;

  Future<Database> get database async {
    final db = _database;
    if (db != null) {
      return db;
    }

    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);

    final openedDatabase = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $categoryTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');

        await db.execute('''
          CREATE TABLE $noteTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            categoryId INTEGER NOT NULL,
            FOREIGN KEY (categoryId) REFERENCES $categoryTable(id)
              ON UPDATE CASCADE
              ON DELETE CASCADE
          )
        ''');
      },
    );

    _database = openedDatabase;
    return openedDatabase;
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert(
      categoryTable,
      {'name': category.name.trim()},
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query(
      categoryTable,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return maps.map(Category.fromMap).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert(noteTable, note.toMap());
  }

  Future<List<Note>> getNotes({int? categoryId}) async {
    final db = await database;

    final maps = await db.rawQuery(
      '''
      SELECT n.id,
             n.title,
             n.content,
             n.categoryId,
             c.name AS categoryName
      FROM $noteTable n
      INNER JOIN $categoryTable c ON c.id = n.categoryId
      ${categoryId == null ? '' : 'WHERE n.categoryId = ?'}
      ORDER BY n.id DESC
      ''',
      categoryId == null ? <Object?>[] : <Object?>[categoryId],
    );

    return maps.map(Note.fromMap).toList();
  }
}

