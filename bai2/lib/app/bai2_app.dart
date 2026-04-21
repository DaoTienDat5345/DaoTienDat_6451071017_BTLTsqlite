import 'package:flutter/material.dart';

import '../controllers/notes_controller.dart';
import '../data/models/category.dart' as category_models;
import '../data/models/note.dart' as note_models;

class Bai2App extends StatelessWidget {
  const Bai2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bài 2 - Ghi chú có danh mục',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  late final NotesController _controller;
  final _categoryNameController = TextEditingController();
  final _noteTitleController = TextEditingController();
  final _noteContentController = TextEditingController();
  int? _noteCategoryId;

  @override
  void initState() {
    super.initState();
    _controller = NotesController();
    _controller.addListener(_syncSelectedCategory);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _syncSelectedCategory();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_syncSelectedCategory);
    _controller.dispose();
    _categoryNameController.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  void _syncSelectedCategory() {
    if (!mounted) {
      return;
    }

    final categories = _controller.categories;
    final selectedIsValid = _noteCategoryId != null &&
        categories.any((category) => category.id == _noteCategoryId);
    final nextValue = categories.isEmpty
        ? null
        : (selectedIsValid ? _noteCategoryId : categories.first.id);

    if (nextValue != _noteCategoryId) {
      setState(() {
        _noteCategoryId = nextValue;
      });
    }
  }

  Future<void> _handleAddCategory() async {
    final insertedId = await _controller.addCategory(_categoryNameController.text);
    if (!mounted) {
      return;
    }

    if (insertedId != null) {
      setState(() {
        _noteCategoryId = insertedId;
      });
      _categoryNameController.clear();
    }
  }

  Future<void> _handleAddNote() async {
    final success = await _controller.addNote(
      title: _noteTitleController.text,
      content: _noteContentController.text,
      categoryId: _noteCategoryId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _noteTitleController.clear();
      _noteContentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ghi chú có danh mục'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.note_alt_outlined), text: 'Ghi chú'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Danh mục'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return TabBarView(
              children: [
                _buildNotesTab(context),
                _buildCategoriesTab(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotesTab(BuildContext context) {
    final categories = _controller.categories;
    final notes = _controller.notes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoBanner(message: _controller.message),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Tạo ghi chú mới',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _noteTitleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteContentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _noteCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map<DropdownMenuItem<int?>>(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: categories.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _noteCategoryId = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _controller.isLoading || categories.isEmpty
                    ? null
                    : _handleAddNote,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Lưu ghi chú'),
              ),
              if (categories.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Hãy tạo ít nhất một danh mục trước khi thêm ghi chú.',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Lọc theo danh mục',
          child: DropdownButtonFormField<int?>(
            initialValue: _controller.selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Bộ lọc',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả danh mục'),
              ),
                ...categories.map<DropdownMenuItem<int?>>(
                  (category) => DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
            ],
            onChanged: (value) => _controller.setCategoryFilter(value),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Danh sách ghi chú',
          child: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : notes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Chưa có ghi chú nào.'),
                    )
                  : Column(
                      children: notes
                          .map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _NoteTile(note: note),
                            ),
                          )
                          .toList(),
                    ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    final categories = _controller.categories;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoBanner(message: _controller.message),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Tạo danh mục mới',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên danh mục',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _controller.isLoading ? null : _handleAddCategory,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Thêm danh mục'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Danh sách danh mục',
          child: categories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Chưa có danh mục nào.'),
                )
              : Column(
                  children: categories
                      .map(
                        (category) => _CategoryTile(
                          category: category,
                          isSelected: category.id == _noteCategoryId,
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }

    final isError = message!.toLowerCase().contains('không') ||
        message!.toLowerCase().contains('để trống') ||
        message!.toLowerCase().contains('vui lòng');
    final background = isError
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.primaryContainer;
    final foreground = isError
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message!,
        style: TextStyle(color: foreground),
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});

  final note_models.Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        title: Text(note.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(note.categoryName ?? 'Không rõ danh mục')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.isSelected});

  final category_models.Category category;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.label_outline,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(category.name),
      trailing: isSelected ? const Text('Đang chọn') : null,
    );
  }
}




