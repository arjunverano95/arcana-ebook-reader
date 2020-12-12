// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookstore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$Bookstore on _Bookstore, Store {
  final _$booksAtom = Atom(name: '_Bookstore.books');

  @override
  List<Book> get books {
    _$booksAtom.reportRead();
    return super.books;
  }

  @override
  set books(List<Book> value) {
    _$booksAtom.reportWrite(value, super.books, () {
      super.books = value;
    });
  }

  final _$getBooksAsyncAction = AsyncAction('_Bookstore.getBooks');

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
