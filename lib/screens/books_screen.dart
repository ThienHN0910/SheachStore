import 'package:flutter/material.dart';

import '../core/storage/token_storage.dart';
import '../models/catalog_models.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';
import 'auth_screen.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _bookService = BookService();
  final _authService = AuthService(tokenStorage: TokenStorage());
  late Future<List<BookResponse>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookService.getBooks();
  }

  void _refresh() {
    setState(() => _booksFuture = _bookService.getBooks());
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          onAuthenticated: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BooksScreen()),
            );
          },
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _openCart() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
    _refresh();
  }

  Future<void> _openOrders() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
  }

  Future<void> _openBook(BookResponse book) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SheachStore'),
        actions: [
          IconButton(
            tooltip: 'Orders',
            onPressed: _openOrders,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<BookResponse>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingState();
            }

            if (snapshot.hasError) {
              return ErrorState(
                message: snapshot.error.toString(),
                onRetry: _refresh,
                onLogout: _logout,
              );
            }

            final books = snapshot.data ?? [];
            if (books.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  EmptyState(
                    title: 'No books yet',
                    message: 'Add books from the WebApi admin endpoints.',
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    onTap: () => _openBook(book),
                    leading: _BookCover(url: book.coverUrl),
                    title: Text(book.title),
                    subtitle: Text(
                      [
                        if (book.authorName != null) book.authorName!,
                        if (book.categoryName != null) book.categoryName!,
                        '${book.stock} in stock',
                      ].join(' • '),
                    ),
                    trailing: Text(
                      formatMoney(book.price),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 48,
      height: 64,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.menu_book_outlined),
    );

    if (url == null || url!.isEmpty) {
      return placeholder;
    }

    return SizedBox(
      width: 48,
      height: 64,
      child: Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
