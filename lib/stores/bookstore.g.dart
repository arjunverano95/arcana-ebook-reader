// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookstore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Bookstore on BookstoreBase, Store {
  late final _$booksAtom = Atom(name: 'BookstoreBase.books', context: context);

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

  late final _$favoriteBooksAtom = Atom(
    name: 'BookstoreBase.favoriteBooks',
    context: context,
  );

  @override
  List<Book> get favoriteBooks {
    _$favoriteBooksAtom.reportRead();
    return super.favoriteBooks;
  }

  @override
  set favoriteBooks(List<Book> value) {
    _$favoriteBooksAtom.reportWrite(value, super.favoriteBooks, () {
      super.favoriteBooks = value;
    });
  }

  late final _$recentlyReadBooksAtom = Atom(
    name: 'BookstoreBase.recentlyReadBooks',
    context: context,
  );

  @override
  List<Book> get recentlyReadBooks {
    _$recentlyReadBooksAtom.reportRead();
    return super.recentlyReadBooks;
  }

  @override
  set recentlyReadBooks(List<Book> value) {
    _$recentlyReadBooksAtom.reportWrite(value, super.recentlyReadBooks, () {
      super.recentlyReadBooks = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'BookstoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$getBooksAsyncAction = AsyncAction(
    'BookstoreBase.getBooks',
    context: context,
  );

  @override
  Future<void> getBooks() {
    return _$getBooksAsyncAction.run(() => super.getBooks());
  }

  late final _$getFavoriteBooksAsyncAction = AsyncAction(
    'BookstoreBase.getFavoriteBooks',
    context: context,
  );

  @override
  Future<void> getFavoriteBooks() {
    return _$getFavoriteBooksAsyncAction.run(() => super.getFavoriteBooks());
  }

  late final _$getRecentlyReadBooksAsyncAction = AsyncAction(
    'BookstoreBase.getRecentlyReadBooks',
    context: context,
  );

  @override
  Future<void> getRecentlyReadBooks() {
    return _$getRecentlyReadBooksAsyncAction.run(
      () => super.getRecentlyReadBooks(),
    );
  }

  late final _$addBookAsyncAction = AsyncAction(
    'BookstoreBase.addBook',
    context: context,
  );

  @override
  Future<bool> addBook(Book book) {
    return _$addBookAsyncAction.run(() => super.addBook(book));
  }

  late final _$deleteBookAsyncAction = AsyncAction(
    'BookstoreBase.deleteBook',
    context: context,
  );

  @override
  Future<bool> deleteBook(String id) {
    return _$deleteBookAsyncAction.run(() => super.deleteBook(id));
  }

  late final _$toggleFavoriteAsyncAction = AsyncAction(
    'BookstoreBase.toggleFavorite',
    context: context,
  );

  @override
  Future<bool> toggleFavorite(String id) {
    return _$toggleFavoriteAsyncAction.run(() => super.toggleFavorite(id));
  }

  late final _$updateLastReadAsyncAction = AsyncAction(
    'BookstoreBase.updateLastRead',
    context: context,
  );

  @override
  Future<bool> updateLastRead(String id) {
    return _$updateLastReadAsyncAction.run(() => super.updateLastRead(id));
  }

  late final _$updateLastReadLocatorAsyncAction = AsyncAction(
    'BookstoreBase.updateLastReadLocator',
    context: context,
  );

  @override
  Future<bool> updateLastReadLocator(String id, String locator) {
    return _$updateLastReadLocatorAsyncAction.run(
      () => super.updateLastReadLocator(id, locator),
    );
  }

  late final _$updateReadingProgressAsyncAction = AsyncAction(
    'BookstoreBase.updateReadingProgress',
    context: context,
  );

  @override
  Future<bool> updateReadingProgress(
    String id,
    int currentPage,
    double progressPercent,
  ) {
    return _$updateReadingProgressAsyncAction.run(
      () => super.updateReadingProgress(id, currentPage, progressPercent),
    );
  }

  late final _$searchBooksAsyncAction = AsyncAction(
    'BookstoreBase.searchBooks',
    context: context,
  );

  @override
  Future<List<Book>> searchBooks(String query) {
    return _$searchBooksAsyncAction.run(() => super.searchBooks(query));
  }

  late final _$refreshAllAsyncAction = AsyncAction(
    'BookstoreBase.refreshAll',
    context: context,
  );

  @override
  Future<void> refreshAll() {
    return _$refreshAllAsyncAction.run(() => super.refreshAll());
  }

  @override
  String toString() {
    return '''
books: ${books},
favoriteBooks: ${favoriteBooks},
recentlyReadBooks: ${recentlyReadBooks},
isLoading: ${isLoading}
    ''';
  }
}
