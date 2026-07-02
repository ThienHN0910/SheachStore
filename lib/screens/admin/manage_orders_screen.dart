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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully')),
        );
      }
      _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _deleteOrder(OrderResponse order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _orderService.deleteOrder(order.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order deleted successfully')),
          );
        }
        _refresh();
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
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
            return const EmptyState(
              title: 'No orders yet',
              message: 'Customer orders will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(12),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(formatDate(order.createdAt)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Customer: ${order.userFullName ?? "Unknown"}'),
                        Text('Total: ${formatMoney(order.totalAmount)}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusChip(status: order.status),
                            const Spacer(),
                            DropdownButton<OrderStatus>(
                              value: order.status,
                              icon: const Icon(Icons.arrow_drop_down),
                              underline: const SizedBox(),
                              items: OrderStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(orderStatusLabel(status)),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null && newStatus != order.status) {
                                  _updateStatus(order, newStatus);
                                }
                              },
                            ),
                            if (order.status == OrderStatus.pending || order.status == OrderStatus.cancelled) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteOrder(order),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    children: [
                      const Divider(height: 1),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Items',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${item.quantity}x'),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(item.bookTitle ?? 'Unknown Book'),
                                      ),
                                      Text(formatMoney(item.lineTotal)),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),
                            const Text(
                              'Shipping Address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(order.shippingAddress),
                          ],
                        ),
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
      OrderStatus.paid => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
