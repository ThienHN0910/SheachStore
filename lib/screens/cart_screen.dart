import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api/api_exception.dart';
import '../models/cart_models.dart';
import '../models/order_models.dart';
import 'orders_screen.dart';
import '../services/cart_service.dart';
import '../services/book_service.dart';
import '../services/order_service.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _quickShippingAddress = 'Mua nhanh';

  final _cartService = CartService();
  final _bookService = BookService();
  final _orderService = OrderService();
  
  late Future<CartResponse> _cartFuture;
  var _isCheckingOut = false;
  
  final Map<int, String> _bookCovers = {};

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCartAndCovers();
  }

  Future<CartResponse> _loadCartAndCovers() async {
    final cart = await _cartService.getCart();
    
    // Fetch covers concurrently for items that are not in cache
    final futures = cart.items.map((item) async {
      if (!_bookCovers.containsKey(item.bookId)) {
        try {
          final book = await _bookService.getBook(item.bookId);
          if (book.coverUrl != null) {
            _bookCovers[item.bookId] = book.coverUrl!;
          }
        } catch (_) {
          // Handled silently, falls back to cover fallback icon
        }
      }
    }).toList();
    
    await Future.wait(futures);
    return cart;
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _cartFuture = _loadCartAndCovers();
      });
    }
  }

  Future<void> _updateQuantity(CartItemResponse item, int quantity) async {
    if (quantity < 1) {
      await _removeItem(item.id);
      return;
    }

    try {
      await _cartService.updateItem(
        item.id,
        UpdateCartItemRequest(quantity: quantity),
      );
      _refresh();
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      await _cartService.removeItem(itemId);
      _refresh();
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    }
  }

  Future<void> _clearCart() async {
    try {
      await _cartService.clearCart();
      _refresh();
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    }
  }

  Future<void> _checkout(CartResponse cart) async {
    setState(() => _isCheckingOut = true);
    try {
      final result = await _orderService.createPayOsOrder(
        CreateOrderRequest(
          shippingAddress: _quickShippingAddress,
          items: cart.items
              .map(
                (item) => CreateOrderItemRequest(
                  bookId: item.bookId,
                  quantity: item.quantity,
                ),
              )
              .toList(),
        ),
      );

      final uri = Uri.parse(result.checkoutUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Could not open PayOS checkout.');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(content: Text('PayOS checkout opened in browser.')),
        );

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        );
        _refresh();
      }
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: FutureBuilder<CartResponse>(
        future: _cartFuture,
        builder: (context, snapshot) {
          final isWaiting = snapshot.connectionState != ConnectionState.done;

          if (isWaiting && !snapshot.hasData) {
            return const LoadingState();
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final cart = snapshot.data!;
          if (cart.items.isEmpty) {
            return const EmptyState(
              title: 'Your cart is empty',
              message: 'Add books from the catalog to start an order.',
            );
          }

          return Column(
            children: [
              if (isWaiting) const LinearProgressIndicator(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final coverUrl = _bookCovers[item.bookId];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book cover thumbnail
                            Container(
                              width: 60,
                              height: 84,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: coverUrl != null && coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _buildCoverPlaceholder(theme),
                                      )
                                    : _buildCoverPlaceholder(theme),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details and controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.bookTitle ?? 'Book #${item.bookId}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: isWaiting ? null : () => _removeItem(item.id),
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        color: theme.colorScheme.error,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(item.unitPrice),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Rounded quantity editor
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: theme.colorScheme.outlineVariant),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: isWaiting ? null : () =>
                                                  _updateQuantity(item, item.quantity - 1),
                                              icon: const Icon(Icons.remove, size: 16),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                            ),
                                            SizedBox(
                                              width: 32,
                                              child: Text(
                                                '${item.quantity}',
                                                textAlign: TextAlign.center,
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: isWaiting ? null : () =>
                                                  _updateQuantity(item, item.quantity + 1),
                                              icon: const Icon(Icons.add, size: 16),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Line total
                                      Text(
                                        formatMoney(item.lineTotal),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Sticky bottom Checkout Panel
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            formatMoney(cart.totalAmount),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isCheckingOut ? null : _clearCart,
                              icon: const Icon(Icons.remove_shopping_cart_outlined, size: 18),
                              label: const Text('Clear Cart'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.colorScheme.error),
                                foregroundColor: theme.colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: _isCheckingOut ? null : () => _checkout(cart),
                              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                              label: Text(_isCheckingOut ? 'Checking out...' : 'Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCoverPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        color: theme.colorScheme.outline,
        size: 24,
      ),
    );
  }
}
