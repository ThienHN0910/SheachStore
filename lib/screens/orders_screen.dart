import 'package:flutter/material.dart';

import '../models/api_enums.dart';
import '../models/order_models.dart';
import '../services/order_service.dart';
import '../widgets/app_states.dart';
import '../widgets/formatters.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();
  late Future<List<OrderResponse>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getMyOrders();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = _orderService.getMyOrders();
    });
  }

  Color _getStatusColor(OrderStatus status, ThemeData theme) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.amber.shade800;
      case OrderStatus.paid:
      case OrderStatus.completed:
        return Colors.green.shade700;
      case OrderStatus.processing:
      case OrderStatus.shipped:
        return theme.colorScheme.primary;
      case OrderStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<OrderResponse>>(
          future: _ordersFuture,
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

            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  EmptyState(
                    title: 'No orders yet',
                    message: 'Checkout from your cart to create an order.',
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status, theme);

                return Card(
                  child: ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Row(
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            order.status.value.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        formatDate(order.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: Text(
                      formatMoney(order.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      const Divider(),
                      ...order.items.map(
                        (item) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            item.bookTitle ?? 'Book #${item.bookId}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${item.quantity} x ${formatMoney(item.unitPrice)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          trailing: Text(
                            formatMoney(item.lineTotal),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
