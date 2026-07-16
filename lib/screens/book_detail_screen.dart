import 'package:flutter/material.dart';

import '../core/api/api_exception.dart';
import '../models/cart_models.dart';
import '../models/catalog_models.dart';
import '../models/review_models.dart';
import '../services/book_service.dart';
import '../services/cart_service.dart';
import '../services/review_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';
import 'cart_screen.dart';

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
  final _wishlistService = WishlistService();
  final _commentController = TextEditingController();

  late Future<_BookDetailData> _detailFuture;
  var _quantity = 1;
  var _rating = 5;
  var _isAddingToCart = false;
  var _isSubmittingReview = false;
  var _isFavorite = false;
  var _isTogglingFavorite = false;

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
      _wishlistService.checkWishlist(widget.bookId),
    ]);

    final isFav = results[2] as bool;
    _isFavorite = isFav;

    return _BookDetailData(
      book: results[0] as BookResponse,
      reviews: results[1] as List<ReviewResponse>,
      isFavorite: isFav,
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
      _isFavorite = !_isFavorite;
    });

    try {
      if (_isFavorite) {
        await _wishlistService.addToWishlist(widget.bookId);
      } else {
        await _wishlistService.removeFromWishlist(widget.bookId);
      }
    } catch (error) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
      _showError(error.toString());
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _detailFuture = _load();
      });
    }
  }

  Future<void> _addToCart(BookResponse book) async {
    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addItem(
        CartItemRequest(bookId: book.id, quantity: _quantity),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: const Text('Added to cart'),
            action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
          ),
        );
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
    final theme = Theme.of(context);

    return FutureBuilder<_BookDetailData>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Details')),
            body: const LoadingState(),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Details')),
            body: ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            ),
          );
        }

        final data = snapshot.data!;
        final book = data.book;
        final isOutOfStock = book.stock == 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Book Details'),
            actions: [
              IconButton(
                tooltip: 'Wishlist',
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Beautiful centered vertical cover
              Center(
                child: Hero(
                  tag: 'book_cover_${book.id}',
                  child: Container(
                    height: 250,
                    width: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: (book.coverUrl ?? '').isNotEmpty
                          ? Image.network(
                              book.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const _CoverFallback(),
                            )
                          : const _CoverFallback(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Category tag (small)
              if (book.categoryName != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      book.categoryName!.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Title
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Author
              if (book.authorName != null)
                Text(
                  'By ${book.authorName}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 16),
              // Price and Stock summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'PRICE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(book.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          'AVAILABILITY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOutOfStock ? 'Out of Stock' : '${book.stock} Books Left',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isOutOfStock ? theme.colorScheme.error : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Description
              if ((book.description ?? '').isNotEmpty) ...[
                Text(
                  'About this book',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  book.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Quantity selector and Add to Cart Row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove, size: 20),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _quantity < book.stock
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isOutOfStock || _isAddingToCart
                          ? null
                          : () => _addToCart(book),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        _isAddingToCart ? 'Adding...' : 'Add to Cart',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // Reviews Header
              Text(
                'Customer Reviews',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Write a review card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rate this book',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _StarRatingInput(
                      rating: _rating,
                      onRatingChanged: (val) => setState(() => _rating = val),
                      enabled: !_isSubmittingReview,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Write a comment (optional)',
                        hintText: 'Share what you thought about this book...',
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isSubmittingReview ? null : _submitReview,
                      icon: const Icon(Icons.rate_review_outlined),
                      label: Text(_isSubmittingReview ? 'Submitting...' : 'Submit Review'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Reviews List
              if (data.reviews.isEmpty)
                const EmptyState(
                  title: 'No reviews yet',
                  message: 'Be the first customer to review this book.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.reviews.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ReviewTile(review: data.reviews[index]);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BookDetailData {
  const _BookDetailData({
    required this.book,
    required this.reviews,
    required this.isFavorite,
  });

  final BookResponse book;
  final List<ReviewResponse> reviews;
  final bool isFavorite;
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final bool enabled;

  const _StarRatingInput({
    required this.rating,
    required this.onRatingChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= rating;
        return IconButton(
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            size: 32,
          ),
          color: isSelected ? const Color(0xFFF59E0B) : Colors.grey.shade400,
          onPressed: enabled ? () => onRatingChanged(starValue) : null,
        );
      }),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ReviewResponse review;

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getAvatarColor(String? name) {
    if (name == null || name.isEmpty) return const Color(0xFF0F766E);
    final colors = [
      const Color(0xFF0F766E), // Teal
      const Color(0xFF0284C7), // Sky Blue
      const Color(0xFF7C3AED), // Violet
      const Color(0xFFDB2777), // Pink
      const Color(0xFFEA580C), // Orange
      const Color(0xFF059669), // Emerald
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(review.userFullName);
    final avatarColor = _getAvatarColor(review.userFullName);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: avatarColor,
              radius: 20,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.userFullName ?? 'Customer',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatDate(review.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (starIdx) {
                      return Icon(
                        starIdx < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.comment ?? 'No comment',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
