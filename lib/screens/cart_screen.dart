import 'package:flutter/material.dart';

import '../core/api/api_exception.dart';
import '../models/api_enums.dart';
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
  final _cartService = CartService();
  final _orderService = OrderService();
  final _addressController = TextEditingController();
  late Future<CartResponse> _cartFuture;
  var _paymentMethod = PaymentMethod.cashOnDelivery;
  var _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCart();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() => _cartFuture = _cartService.getCart());
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
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showError('Shipping address is required.');
      return;
    }

    setState(() => _isCheckingOut = true);
    try {
      await _orderService.createOrder(
        CreateOrderRequest(
          paymentMethod: _paymentMethod,
          shippingAddress: address,
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
      await _cartService.clearCart();
      _addressController.clear();
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order created')));
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
          if (snapshot.connectionState != ConnectionState.done) {
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

          return ListView(
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
                              onPressed: () => _removeItem(item.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        Text(formatMoney(item.unitPrice)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () =>
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
                              onPressed: () =>
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
              TextField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Shipping address',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: PaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(paymentMethodLabel(method)),
                      ),
                    )
                    .toList(),
                onChanged: _isCheckingOut
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _paymentMethod = value);
                        }
                      },
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
          );
        },
      ),
    );
  }
}
