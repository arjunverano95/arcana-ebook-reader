import 'package:arcana_ebook_reader/util/hiveContext.dart';

import 'stores/bookstore.dart';
import 'package:arcana_ebook_reader/util/navigation.dart';

BuildEnvironment get env => _env;
late BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final Bookstore bookstore;
  final Navigation navigation;
  final HiveContext context;

  BuildEnvironment._init(
      {required this.context,
      required this.bookstore,
      required this.navigation});

  /// Sets up the top-level [env] getter on the first call only.
  static Future<void> init() async {
    var context = HiveContext();
    await context.init();

    //Get env Config
    _env = BuildEnvironment._init(
        context: context, bookstore: Bookstore(), navigation: Navigation());
    await _env.bookstore.getBooks();
  }
}
