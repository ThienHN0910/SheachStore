import 'package:flutter/material.dart';
import 'manage_books_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_authors_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';

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
          _AdminCard(
            title: 'Manage Users',
            icon: Icons.people_outline,
            color: Colors.red,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
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
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

