// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookstore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Bookstore on BookstoreBase, Store {
  late final _$booksAtom = Atom(name: 'BookstoreBase.books', context: context);

  @override
  List<BookDto> get books {
    _$booksAtom.reportRead();
    return super.books;
  }

  @override
  set books(List<BookDto> value) {
    _$booksAtom.reportWrite(value, super.books, () {
      super.books = value;
    });
  }

  late final _$getBooksAsyncAction =
      AsyncAction('BookstoreBase.getBooks', context: context);

  @override
  Future<void> getBooks() {
    return _$getBooksAsyncAction.run(() => super.getBooks());
  }

  @override
  String toString() {
    return '''
books: ${books}
    ''';
  }
}
