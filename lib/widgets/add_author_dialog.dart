import 'package:flutter/material.dart';
import '../services/author_service.dart';
import '../models/catalog_models.dart';

class AddAuthorDialog extends StatefulWidget {
  const AddAuthorDialog({super.key, required this.authorService});

  final AuthorService authorService;

  @override
  State<AddAuthorDialog> createState() => _AddAuthorDialogState();
}

class _AddAuthorDialogState extends State<AddAuthorDialog> {
  final _controller = TextEditingController();
  var _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final author = await widget.authorService.createAuthor(AuthorRequest(name: name));
      if (mounted) Navigator.pop(context, author);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Author'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Author Name'),
        autofocus: true,
        enabled: !_isSubmitting,
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
