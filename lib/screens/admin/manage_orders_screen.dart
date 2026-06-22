import 'package:flutter/material.dart';
import '../../core/api/api_exception.dart';
import '../../models/api_enums.dart';
import '../../models/order_models.dart';
import '../../services/order_service.dart';
import '../../widgets/app_states.dart';
import '../../widgets/formatters.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final _orderService = OrderService();
  late Future<List<OrderResponse>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final future = _orderService.getOrders();
    setState(() {
      _ordersFuture = future;
    });
  }

  Future<void> _updateStatus(OrderResponse order, OrderStatus newStatus) async {
    try {
      await _orderService.updateStatus(order.id, newStatus);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: FutureBuilder<List<OrderResponse>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const LoadingState();
          if (snapshot.hasError) return ErrorState(message: snapshot.error.toString(), onRetry: _refresh);

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const EmptyState(title: 'No orders yet', message: 'Customer orders will appear here.');
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(formatDate(order.createdAt)),
                        ],
                      ),
                      const Divider(),
                      Text('Customer: ${order.userFullName ?? "Unknown"}'),
                      Text('Total: ${formatMoney(order.totalAmount)}'),
                      Text('Address: ${order.shippingAddress}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatusChip(status: order.status),
                          const Spacer(),
                          PopupMenuButton<OrderStatus>(
                            onSelected: (status) => _updateStatus(order, status),
                            itemBuilder: (context) => OrderStatus.values
                                .map((s) => PopupMenuEntry<OrderStatus>(
                                      value: s,
                                      child: Text(orderStatusLabel(s)),
                                    ))
                                .toList(),
                            child: OutlinedButton.icon(
                              onPressed: null, // PopupMenuButton handles tap
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Update Status'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.paid => Colors.blue,
      OrderStatus.processing => Colors.indigo,
      OrderStatus.shipped => Colors.purple,
      OrderStatus.completed => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        orderStatusLabel(status),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
