import 'package:flutter/material.dart';
import 'manage_books_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_authors_screen.dart';
import 'manage_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _AdminCard(
            title: 'Manage Books',
            icon: Icons.book_outlined,
            color: Colors.blue,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
            ),
          ),
          _AdminCard(
            title: 'Manage Orders',
            icon: Icons.shopping_bag_outlined,
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
            ),
          ),
          _AdminCard(
            title: 'Categories',
            icon: Icons.category_outlined,
            color: Colors.green,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
            ),
          ),
          _AdminCard(
            title: 'Authors',
            icon: Icons.person_outline,
            color: Colors.purple,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageAuthorsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
