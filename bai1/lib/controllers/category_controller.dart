import '../data/models/category_model.dart';
import '../data/repository/category_repository.dart';

class CategoryController {
  final CategoryRepository _repository = CategoryRepository();

  Future<List<Category>> getCategories() async {
    return await _repository.getAll();
  }

  Future<void> addCategory(String name) async {
    await _repository.insert(Category(name: name));
  }

  Future<void> updateCategory(Category category) async {
    await _repository.update(category);
  }

  Future<void> deleteCategory(int id) async {
    await _repository.delete(id);
  }
}
