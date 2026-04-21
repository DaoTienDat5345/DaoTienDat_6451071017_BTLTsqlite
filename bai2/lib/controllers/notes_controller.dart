import 'package:flutter/foundation.dart';

import '../data/models/category.dart' as category_models;
import '../data/models/note.dart' as note_models;
import '../data/repository/notes_repository.dart';

class NotesController extends ChangeNotifier {
  NotesController({NotesRepository? repository})
      : _repository = repository ?? NotesRepository();

  final NotesRepository _repository;

  final List<category_models.Category> _categories = [];
  final List<note_models.Note> _notes = [];

  bool _isLoading = false;
  int? _selectedCategoryId;
  String? _message;

  List<category_models.Category> get categories => List.unmodifiable(_categories);
  List<note_models.Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get message => _message;

  Future<void> initialize() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      await Future.wait([_loadCategories(), _loadNotes()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([_loadCategories(), _loadNotes()]);
  }

  Future<void> setCategoryFilter(int? categoryId) async {
    _selectedCategoryId = categoryId;
    notifyListeners();
    await _loadNotes();
  }

  Future<int?> addCategory(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      _message = 'Tên danh mục không được để trống.';
      notifyListeners();
      return null;
    }

    try {
      final id = await _repository.addCategory(normalized);
      _message = 'Đã thêm danh mục "$normalized".';
      await _loadCategories();
      return id;
    } catch (_) {
      _message = 'Không thể thêm danh mục. Có thể tên đã tồn tại.';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addNote({
    required String title,
    required String content,
    required int? categoryId,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();

    if (normalizedTitle.isEmpty) {
      _message = 'Tiêu đề ghi chú không được để trống.';
      notifyListeners();
      return false;
    }
    if (normalizedContent.isEmpty) {
      _message = 'Nội dung ghi chú không được để trống.';
      notifyListeners();
      return false;
    }
    if (categoryId == null) {
      _message = 'Vui lòng chọn danh mục cho ghi chú.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.addNote(
        title: normalizedTitle,
        content: normalizedContent,
        categoryId: categoryId,
      );
      _message = 'Đã thêm ghi chú mới.';
      await _loadNotes();
      return true;
    } catch (_) {
      _message = 'Không thể thêm ghi chú. Hãy thử lại.';
      notifyListeners();
      return false;
    }
  }

  void clearMessage() {
    if (_message == null) {
      return;
    }
    _message = null;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _categories
      ..clear()
      ..addAll(await _repository.getCategories());

    if (_selectedCategoryId != null &&
        !_categories.any((category) => category.id == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }

    notifyListeners();
  }

  Future<void> _loadNotes() async {
    _notes
      ..clear()
      ..addAll(await _repository.getNotes(categoryId: _selectedCategoryId));
    notifyListeners();
  }
}




