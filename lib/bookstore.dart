import 'package:arcana_ebook_reader/util/context.dart';
import 'package:mobx/mobx.dart';

part 'bookstore.g.dart';

class Bookstore = _Bookstore with _$Bookstore;

abstract class _Bookstore with Store {
  @observable
  List<Book> books = [];

  @action
  Future<void> getBooks() async {
     books = await Book.get();
  }
}
