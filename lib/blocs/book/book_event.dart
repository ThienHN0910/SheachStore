import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class FetchBooks extends BookEvent {}

class SearchBooks extends BookEvent {
  final String keyword;

  const SearchBooks(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterByCategory extends BookEvent {
  final int categoryId;

  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
