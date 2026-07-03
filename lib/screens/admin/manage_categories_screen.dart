import 'package:flutter/material.dart';
import '../../core/api/api_exception.dart';
import '../../models/catalog_models.dart';
import '../../services/category_service.dart';
import '../../widgets/app_states.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _categoryService = CategoryService();
  late Future<List<CategoryResponse>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = _categoryService.getCategories();
    setState(() {
      _categoriesFuture = future;
    });
  }

  Future<void> _showCategoryDialog([CategoryResponse? category]) async {
    final nameController = TextEditingController(text: category?.name);
    final slugController = TextEditingController(text: category?.slug);
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: errorMessage,
                  errorMaxLines: 3,
                ),
                onChanged: (v) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                  setState(() {
                    if (category == null) {
                      slugController.text = v.toLowerCase().replaceAll(' ', '-');
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: slugController,
                decoration: const InputDecoration(labelText: 'Slug'),
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: nameController.text.trim().isEmpty || slugController.text.trim().isEmpty
                  ? null
                  : () async {
                      final request = CategoryRequest(
                        name: nameController.text.trim(),
                        slug: slugController.text.trim(),
                      );
                      try {
                        if (category == null) {
                          await _categoryService.createCategory(request);
                        } else {
                          await _categoryService.updateCategory(category.id, request);
                        }
                        if (context.mounted) Navigator.pop(context, true);
                      } on ApiException catch (e) {
                        setState(() => errorMessage = e.message);
                      } catch (e) {
                        setState(() => errorMessage = e.toString());
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(category == null
                ? 'Category created successfully'
                : 'Category updated successfully'),
          ),
        );
      }
      _refresh();
    }
  }

  Future<void> _deleteCategory(CategoryResponse category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _categoryService.deleteCategory(category.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        }
        _refresh();
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: FutureBuilder<List<CategoryResponse>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: _refresh);

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const EmptyState(
              title: 'No categories yet',
              message: 'Add a category to start classifying books.',
            );
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                title: Text(cat.name),
                subtitle: Text(cat.slug),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showCategoryDialog(cat)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(cat),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
