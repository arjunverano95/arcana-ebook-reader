import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:mobx/mobx.dart';

part 'bookstore.g.dart';

class Bookstore = _Bookstore with _$Bookstore;

abstract class _Bookstore with Store {
  @observable
  List<BookDto> books = [];

  @action
  Future<void> getBooks() async {
    var newBooks = await BookLibrary.getAll();
    List<BookDto> oldBooks = List.from(books);
    final lookup = Map.fromIterable(oldBooks,
        key: (m) => m.id as String, value: (m) => m as BookDto);

    newBooks = newBooks.map((book) {
      var oldBook = lookup[book.id];
      if (oldBook != null) book.coverImageData = oldBook.coverImageData;
      return book;
    }).toList();

    books = newBooks;
  }
}
// flutter packages pub run build_runner build
