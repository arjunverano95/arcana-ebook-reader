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

    books = newBooks;
  }
}
// flutter packages pub run build_runner build
