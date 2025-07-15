import 'package:arcana_ebook_reader/services/database_service.dart';
import 'package:arcana_ebook_reader/util/navigation.dart';
import 'stores/bookstore.dart';

BuildEnvironment get env => _env;
late BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final Bookstore bookstore;
  final Navigation navigation;

  BuildEnvironment._init({required this.bookstore, required this.navigation});

  /// Sets up the top-level [env] getter on the first call only.
  static Future<void> init() async {
    // Initialize database
    await DatabaseService.initialize();

    //Get env Config
    _env = BuildEnvironment._init(
      bookstore: Bookstore(),
      navigation: Navigation(),
    );
    await _env.bookstore.getBooks();
  }
}
