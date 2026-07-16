import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/book/book_bloc.dart';
import '../blocs/book/book_event.dart';
import '../blocs/book/book_state.dart';
import '../models/api_enums.dart';
import '../models/catalog_models.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _searchController = TextEditingController();

  List<CategoryResponse> _categories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _selectedCategoryId = null;
    });
    context.read<BookBloc>().add(FetchBooks());
  }
  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SheachStore'),
        centerTitle: false,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated && state.user.role == UserRole.admin) {
                return IconButton(
                  tooltip: 'Admin Panel',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            tooltip: 'Orders',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
              _refresh();
            },
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
              _refresh();
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refresh();
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = null;
                });
                context.read<BookBloc>().add(SearchBooks(value));
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilterRow(theme),
            Expanded(
              child: BlocConsumer<BookBloc, BookState>(
                listener: (context, state) {
                  if (state is BookLoaded) {
                    if (_selectedCategoryId == null && _searchController.text.isEmpty) {
                      final uniqueCategories = <int, String>{};
                      for (final book in state.books) {
                        if (book.categoryName != null) {
                          uniqueCategories[book.categoryId] = book.categoryName!;
                        }
                      }
                      setState(() {
                        _categories = uniqueCategories.entries
                            .map((e) => CategoryResponse(
                                  id: e.key,
                                  name: e.value,
                                  slug: '',
                                ))
                            .toList();
                      });
                    }
                  }
                },
                builder: (context, state) {
                  if (state is BookLoading) {
                    return const LoadingState();
                  }

                  if (state is BookError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: _refresh,
                      onLogout: _logout,
                    );
                  }

                  if (state is BookLoaded) {
                    final books = state.books;
                    if (books.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 100),
                          EmptyState(
                            title: 'No books found',
                            message: 'Try a different search term or check back later.',
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: books.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _BookCard(
                          book: book,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(bookId: book.id),
                              ),
                            );
                            _refresh();
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterRow(ThemeData theme) {
    if (_categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _categories[index - 1];
          final isSelected = isAll ? _selectedCategoryId == null : _selectedCategoryId == category!.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(isAll ? 'All Books' : category!.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryId = isAll ? null : category!.id;
                  });
                  _searchController.clear();
                  if (isAll) {
                    context.read<BookBloc>().add(FetchBooks());
                  } else {
                    context.read<BookBloc>().add(FilterByCategory(category!.id));
                  }
                }
              },
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookResponse book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = book.stock == 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover thumbnail with subtle shadow and round corners
              Container(
                width: 80,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildCoverPlaceholder(theme),
                        )
                      : _buildCoverPlaceholder(theme),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (book.authorName != null)
                      Text(
                        book.authorName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (book.categoryName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              book.categoryName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? theme.colorScheme.errorContainer
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOutOfStock ? 'Out of stock' : '${book.stock} in stock',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOutOfStock ? theme.colorScheme.error : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatMoney(book.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book_outlined,
        color: theme.colorScheme.outline,
        size: 32,
      ),
    );
  }
}
