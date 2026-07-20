import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/book/book_bloc.dart';
import 'blocs/book/book_event.dart';
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => BookService()),
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => WishlistService()),
        RepositoryProvider(create: (_) => NotificationService()),
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
          theme: AppTheme.lightTheme,
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
        if (state is Authenticated) {
          return const BooksScreen();
        }

        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AuthScreen(
          onAuthenticated: () {},
        );
      },
    );
  }
}
