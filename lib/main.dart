import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme.dart';

import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'repositories/book_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/books_screen.dart';
import 'services/auth_service.dart';
import 'services/book_service.dart';
import 'services/notification_service.dart';
import 'services/wishlist_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  runApp(const SheachStoreApp());
}

class SheachStoreApp extends StatelessWidget {
  const SheachStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => BookService()),
        Provider(create: (_) => WishlistService()),
        Provider(create: (_) => NotificationService()),
        Provider(
          create: (context) => BookRepository(
            bookService: context.read<BookService>(),
          ),
        ),
        // State providers
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BookProvider(
            bookRepository: context.read<BookRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SheachStore',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppGate(),
      ),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  @override
  void initState() {
    super.initState();
    // Initialize auth & books after first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().init().then((_) {
        if (!mounted) return;
        final auth = context.read<AuthProvider>();
        if (auth.isAuthenticated) {
          context.read<BookProvider>().fetchBooks();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.isAuthenticated) {
      return const BooksScreen();
    }

    return const AuthScreen();
  }
}
