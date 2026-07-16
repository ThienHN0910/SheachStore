import 'package:flutter/material.dart';
import '../core/api/api_exception.dart';
import '../services/author_service.dart';
import '../models/catalog_models.dart';

class AddAuthorDialog extends StatefulWidget {
  const AddAuthorDialog({super.key, required this.authorService});

  final AuthorService authorService;

  @override
  State<AddAuthorDialog> createState() => _AddAuthorDialogState();
}

class _AddAuthorDialogState extends State<AddAuthorDialog> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  var _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final existing = await widget.authorService.getAuthors();
      final isDuplicate = existing.any((a) => a.name.toLowerCase() == name.toLowerCase());
      if (isDuplicate) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'An author with the name "$name" already exists.';
        });
        return;
      }

      final author = await widget.authorService.createAuthor(
        AuthorRequest(
          name: name,
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, author);
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
      title: const Text('Add New Author'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Author Name',
              errorText: _errorMessage,
              errorMaxLines: 3,
            ),
            autofocus: true,
            enabled: !_isSubmitting,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: 'Bio (Optional)'),
            maxLines: 2,
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
