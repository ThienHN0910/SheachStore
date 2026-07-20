import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object?> get props => [];
}

class FetchBooks extends BookEvent {}

class SearchBooks extends BookEvent {
  const SearchBooks(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class FilterByCategory extends BookEvent {
  const FilterByCategory(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}
