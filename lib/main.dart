import 'package:flutter/material.dart';

import 'core/storage/token_storage.dart';
import 'screens/auth_screen.dart';
import 'screens/books_screen.dart';

void main() {
  runApp(const SheachStoreApp());
}

class SheachStoreApp extends StatelessWidget {
  const SheachStoreApp({super.key, this.initialTokenFuture});

  final Future<String?>? initialTokenFuture;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheachStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: _StartupScreen(initialTokenFuture: initialTokenFuture),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen({this.initialTokenFuture});

  final Future<String?>? initialTokenFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: initialTokenFuture ?? TokenStorage().readToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if ((snapshot.data ?? '').isNotEmpty) {
          return const BooksScreen();
        }

        return AuthScreen(
          onAuthenticated: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BooksScreen()),
            );
          },
        );
      },
    );
  }
}
