import 'package:flutter/material.dart';
import '../../core/api/api_exception.dart';
import '../../models/catalog_models.dart';
import '../../services/author_service.dart';
import '../../widgets/app_states.dart';

class ManageAuthorsScreen extends StatefulWidget {
  const ManageAuthorsScreen({super.key});

  @override
  State<ManageAuthorsScreen> createState() => _ManageAuthorsScreenState();
}

class _ManageAuthorsScreenState extends State<ManageAuthorsScreen> {
  final _authorService = AuthorService();
  late Future<List<AuthorResponse>> _authorsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = _authorService.getAuthors();
    setState(() {
      _authorsFuture = future;
    });
  }

  Future<void> _showAuthorDialog([AuthorResponse? author]) async {
    final nameController = TextEditingController(text: author?.name);
    final bioController = TextEditingController(text: author?.bio);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(author == null ? 'Add Author' : 'Edit Author'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final request = AuthorRequest(
        name: nameController.text.trim(),
        bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
      );
      try {
        if (author == null) {
          await _authorService.createAuthor(request);
        } else {
          await _authorService.updateAuthor(author.id, request);
        }
        _refresh();
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    }
  }

  Future<void> _deleteAuthor(AuthorResponse author) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Author'),
        content: Text('Delete "${author.name}"?'),
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
        await _authorService.deleteAuthor(author.id);
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
      appBar: AppBar(title: const Text('Manage Authors')),
      body: FutureBuilder<List<AuthorResponse>>(
        future: _authorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: _refresh);

          final authors = snapshot.data ?? [];
          return ListView.builder(
            itemCount: authors.length,
            itemBuilder: (context, index) {
              final author = authors[index];
              return ListTile(
                title: Text(author.name),
                subtitle: Text(author.bio ?? 'No bio'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAuthorDialog(author)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAuthor(author),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAuthorDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
