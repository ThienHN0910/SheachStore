import 'package:flutter/material.dart';
import '../core/api/api_exception.dart';
import '../services/category_service.dart';
import '../models/catalog_models.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key, required this.categoryService});

  final CategoryService categoryService;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  var _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final slug = _slugController.text.trim().isEmpty
        ? name.toLowerCase().replaceAll(' ', '-')
        : _slugController.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final category = await widget.categoryService.createCategory(
        CategoryRequest(name: name, slug: slug),
      );
      if (mounted) Navigator.pop(context, category);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              errorText: _errorMessage,
              errorMaxLines: 3,
            ),
            autofocus: true,
            enabled: !_isSubmitting,
            onChanged: (v) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
              _slugController.text = v.toLowerCase().replaceAll(' ', '-');
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _slugController,
            decoration: const InputDecoration(labelText: 'Slug'),
            enabled: !_isSubmitting,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add'),
        ),
      ],
    );
  }
}
