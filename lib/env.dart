import 'stores/bookstore.dart';
import 'package:arcana_ebook_reader/util/navigation.dart';

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final Bookstore bookstore;
  final Navigation navigation;

  BuildEnvironment._init({this.bookstore, this.navigation});

  /// Sets up the top-level [env] getter on the first call only.
  static Future<void> init() async {
    //Get env Config
    _env ??= BuildEnvironment._init(
        bookstore: Bookstore(), navigation: Navigation());
    await _env.bookstore.getBooks();
  }
}
