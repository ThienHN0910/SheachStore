import 'package:flutter/material.dart';
import '../../core/api/api_exception.dart';
import '../../models/catalog_models.dart';
import '../../services/author_service.dart';
import '../../services/book_service.dart';
import '../../services/category_service.dart';
import '../../widgets/app_states.dart';

class EditBookScreen extends StatefulWidget {
  const EditBookScreen({super.key, this.book});

  final BookResponse? book;

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookService = BookService();
  final _authorService = AuthorService();
  final _categoryService = CategoryService();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _descriptionController;

  int? _selectedAuthorId;
  int? _selectedCategoryId;
  
  late Future<List<dynamic>> _dataFuture;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title);
    _priceController = TextEditingController(text: widget.book?.price.toString());
    _stockController = TextEditingController(text: widget.book?.stock.toString());
    _coverUrlController = TextEditingController(text: widget.book?.coverUrl);
    _descriptionController = TextEditingController(text: widget.book?.description);
    
    _selectedAuthorId = widget.book?.authorId;
    _selectedCategoryId = widget.book?.categoryId;

    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _dataFuture = Future.wait([
        _authorService.getAuthors(),
        _categoryService.getCategories(),
      ]);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _coverUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addNewAuthor() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Author'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Author Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      try {
        final author = await _authorService.createAuthor(AuthorRequest(name: controller.text.trim()));
        setState(() {
          _selectedAuthorId = author.id;
        });
        _refreshData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _addNewCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final name = controller.text.trim();
      final slug = name.toLowerCase().replaceAll(' ', '-');
      try {
        final category = await _categoryService.createCategory(CategoryRequest(name: name, slug: slug));
        setState(() {
          _selectedCategoryId = category.id;
        });
        _refreshData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAuthorId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select author and category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = BookRequest(
      title: _titleController.text.trim(),
      authorId: _selectedAuthorId!,
      categoryId: _selectedCategoryId!,
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      coverUrl: _coverUrlController.text.trim().isEmpty ? null : _coverUrlController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    try {
      if (widget.book == null) {
        await _bookService.createBook(request);
      } else {
        await _bookService.updateBook(widget.book!.id, request);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState();
          }

          if (snapshot.hasError) {
            return ErrorState(message: snapshot.error.toString(), onRetry: _refreshData);
          }

          final authors = snapshot.data![0] as List<AuthorResponse>;
          final categories = snapshot.data![1] as List<CategoryResponse>;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedAuthorId,
                        decoration: const InputDecoration(labelText: 'Author'),
                        items: authors.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                        onChanged: (v) => setState(() => _selectedAuthorId = v),
                      ),
                    ),
                    IconButton(
                      onPressed: _addNewAuthor,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add new author',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setState(() => _selectedCategoryId = v),
                      ),
                    ),
                    IconButton(
                      onPressed: _addNewCategory,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add new category',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid stock' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coverUrlController,
                  decoration: const InputDecoration(labelText: 'Cover Image URL'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: Text(_isSubmitting ? 'Saving...' : 'Save Book'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
