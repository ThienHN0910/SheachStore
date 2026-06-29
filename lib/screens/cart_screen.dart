import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api/api_exception.dart';
import '../models/cart_models.dart';
import '../models/order_models.dart';
import '../services/cart_service.dart';
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
  final _orderService = OrderService();
  late Future<CartResponse> _cartFuture;
  var _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCart();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _cartFuture = _cartService.getCart();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
              ...cart.items.map(
                (item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.bookTitle ?? 'Book #${item.bookId}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: isWaiting ? null : () => _removeItem(item.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        Text(formatMoney(item.unitPrice)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: isWaiting ? null : () =>
                                  _updateQuantity(item, item.quantity - 1),
                              icon: const Icon(Icons.remove),
                            ),
                            SizedBox(
                              width: 48,
                              child: Text(
                                '${item.quantity}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton.outlined(
                              onPressed: isWaiting ? null : () =>
                                  _updateQuantity(item, item.quantity + 1),
                              icon: const Icon(Icons.add),
                            ),
                            const Spacer(),
                            Text(
                              formatMoney(item.lineTotal),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total: ${formatMoney(cart.totalAmount)}',
                textAlign: TextAlign.end,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isCheckingOut ? null : () => _checkout(cart),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(_isCheckingOut ? 'Checking out...' : 'Checkout'),
              ),
              TextButton.icon(
                onPressed: _isCheckingOut ? null : _clearCart,
                icon: const Icon(Icons.remove_shopping_cart_outlined),
                label: const Text('Clear cart'),
              ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
