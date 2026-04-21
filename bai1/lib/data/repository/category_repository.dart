import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

class CategoryRepository {
  Future<int> insert(Category category) async {
    Database db = await DatabaseService.database;
    return await db.insert('category', category.toMap());
  }

  Future<List<Category>> getAll() async {
    Database db = await DatabaseService.database;
    List<Map<String, dynamic>> result = await db.query('category');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> update(Category category) async {
    Database db = await DatabaseService.database;
    return await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseService.database;
    return await db.delete(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
