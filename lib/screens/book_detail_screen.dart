import 'package:flutter/material.dart';

import '../core/api/api_exception.dart';
import '../models/cart_models.dart';
import '../models/catalog_models.dart';
import '../models/review_models.dart';
import '../services/book_service.dart';
import '../services/cart_service.dart';
import '../services/review_service.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _bookService = BookService();
  final _cartService = CartService();
  final _reviewService = ReviewService();
  final _commentController = TextEditingController();

  late Future<_BookDetailData> _detailFuture;
  var _quantity = 1;
  var _rating = 5;
  var _isAddingToCart = false;
  var _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<_BookDetailData> _load() async {
    final results = await Future.wait([
      _bookService.getBook(widget.bookId),
      _reviewService.getReviewsByBook(widget.bookId),
    ]);

    return _BookDetailData(
      book: results[0] as BookResponse,
      reviews: results[1] as List<ReviewResponse>,
    );
  }

  void _refresh() {
    setState(() => _detailFuture = _load());
  }

  Future<void> _addToCart(BookResponse book) async {
    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addItem(
        CartItemRequest(bookId: book.id, quantity: _quantity),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmittingReview = true);
    try {
      await _reviewService.createReview(
        ReviewRequest(
          bookId: widget.bookId,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        ),
      );
      _commentController.clear();
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted')));
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmittingReview = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: FutureBuilder<_BookDetailData>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState();
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final book = data.book;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if ((book.coverUrl ?? '').isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      book.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CoverFallback(),
                    ),
                  ),
                )
              else
                const _CoverFallback(),
              const SizedBox(height: 16),
              Text(
                book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (book.authorName != null) book.authorName!,
                  if (book.categoryName != null) book.categoryName!,
                ].join(' • '),
              ),
              const SizedBox(height: 8),
              Text(
                formatMoney(book.price),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('${book.stock} in stock'),
              if ((book.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(book.description!),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: _quantity < book.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: book.stock == 0 || _isAddingToCart
                          ? null
                          : () => _addToCart(book),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        _isAddingToCart ? 'Adding...' : 'Add to cart',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _ReviewForm(
                rating: _rating,
                controller: _commentController,
                isSubmitting: _isSubmittingReview,
                onRatingChanged: (value) => setState(() => _rating = value),
                onSubmit: _submitReview,
              ),
              const SizedBox(height: 16),
              if (data.reviews.isEmpty)
                const EmptyState(
                  title: 'No reviews yet',
                  message: 'Be the first customer to review this book.',
                )
              else
                ...data.reviews.map((review) => _ReviewTile(review: review)),
            ],
          );
        },
      ),
    );
  }
}

class _BookDetailData {
  const _BookDetailData({required this.book, required this.reviews});

  final BookResponse book;
  final List<ReviewResponse> reviews;
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu_book_outlined, size: 64),
      ),
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.rating,
    required this.controller,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final int rating;
  final TextEditingController controller;
  final bool isSubmitting;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          initialValue: rating,
          decoration: const InputDecoration(labelText: 'Rating'),
          items: List.generate(5, (index) => index + 1)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text('$value star${value == 1 ? '' : 's'}'),
                ),
              )
              .toList(),
          onChanged: isSubmitting
              ? null
              : (value) {
                  if (value != null) {
                    onRatingChanged(value);
                  }
                },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Comment'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: isSubmitting ? null : onSubmit,
          icon: const Icon(Icons.rate_review_outlined),
          label: Text(isSubmitting ? 'Submitting...' : 'Submit review'),
        ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewResponse review;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(review.rating.toString())),
        title: Text(review.userFullName ?? 'Customer'),
        subtitle: Text(review.comment ?? 'No comment'),
        trailing: Text(formatDate(review.createdAt)),
      ),
    );
  }
}
