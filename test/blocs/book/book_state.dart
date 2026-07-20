import 'package:equatable/equatable.dart';
import 'package:src/models/catalog_models.dart';

abstract class BookState extends Equatable {
  const BookState();

  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  const BookLoaded(this.books);

  final List<BookResponse> books;

  @override
  List<Object?> get props => [books];
}

class BookError extends BookState {
  const BookError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
