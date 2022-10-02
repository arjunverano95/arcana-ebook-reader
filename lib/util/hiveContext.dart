import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveContext {
  late Box<Book> books;
  Future<bool> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(BookAdapter(), override: true);

      await this.openBox();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> openBox() async {
    try {
      books = await Hive.openBox<Book>(BookLibrary.name);
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> closeBox() async {
    try {
      books.close();
      return true;
    } catch (ex) {
      return false;
    }
  }
}
