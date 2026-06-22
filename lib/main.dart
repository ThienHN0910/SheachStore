import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/book/book_bloc.dart';
import 'blocs/book/book_event.dart';
import 'core/storage/token_storage.dart';
import 'repositories/book_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/books_screen.dart';
import 'services/auth_service.dart';
import 'services/book_service.dart';

void main() {
  runApp(const SheachStoreApp());
}

class SheachStoreApp extends StatelessWidget {
  const SheachStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => TokenStorage()),
        RepositoryProvider(create: (_) => BookService()),
        RepositoryProvider(
          create: (context) => AuthService(
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => BookRepository(
            bookService: context.read<BookService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
              tokenStorage: context.read<TokenStorage>(),
            )..add(AppStarted()),
          ),
          BlocProvider(
            create: (context) => BookBloc(
              bookRepository: context.read<BookRepository>(),
            )..add(FetchBooks()),
          ),
        ],
        child: MaterialApp(
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
          home: const _AppGate(),
        ),
      ),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          return const BooksScreen();
        }

        return AuthScreen(
          onAuthenticated: () {
            // Không cần Navigator nữa vì BlocBuilder sẽ tự render BooksScreen khi state là Authenticated
          },
        );
      },
    );
  }
}
