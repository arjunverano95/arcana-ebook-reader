import 'bookstore.dart';



BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final Bookstore bookstore;

  BuildEnvironment._init({this.bookstore});

  /// Sets up the top-level [env] getter on the first call only.
  static Future<void> init() async {
    //Get env Config
      _env ??= BuildEnvironment._init(bookstore: Bookstore(), );
      await _env.bookstore.getBooks();

  }
}