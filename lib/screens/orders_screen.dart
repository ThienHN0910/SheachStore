import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
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
                return Card(
                  child: ExpansionTile(
                    title: Text('Order #${order.id}'),
                    subtitle: Text(formatDate(order.createdAt)),
                    trailing: Text(formatMoney(order.totalAmount)),
                    children: [
                      ...order.items.map(
                        (item) => ListTile(
                          title: Text(item.bookTitle ?? 'Book #${item.bookId}'),
                          subtitle: Text(
                            '${item.quantity} x ${formatMoney(item.unitPrice)}',
                          ),
                          trailing: Text(formatMoney(item.lineTotal)),
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
