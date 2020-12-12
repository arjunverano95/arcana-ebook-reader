import 'dart:convert';

import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Favorites extends StatelessWidget {
  Favorites();
  @override
  Widget build(BuildContext context) {
    return FavoritesBody();
  }
}

class FavoritesBody extends StatefulWidget {
  FavoritesBody();
  @override
  FavoritesBodyState createState() => FavoritesBodyState();
}

class FavoritesBodyState extends State<FavoritesBody> {
  FavoritesBodyState();
  String _sort = "asc";
  bool _loading = true;
  List<Book> _books;
  final isolates = IsolateHandler();
  @override
  void initState() {
    super.initState();
    _getBooks();
  }

  Widget _buildRows(Book book, int index) {
    return BookTile(book:book);
  }

   void mapBooks(String res) {
    var books =
        (json.decode(res) as List).map((i) => Book.fromJson(i)).toList();
    setState(() {
      _books = books;
      _loading = false;
    });
    isolates.kill('getBooks');
  }

  void _getBooks() {
    setState(() {
      _loading = true;
    });
    isolates.spawn<String>(getBooks,
        name: 'getBooks',
        onReceive: mapBooks,
        onInitialized: () => isolates.send("startIsolate", to: 'getBooks'));
  }

  Widget _listBooks(List<Book> books) {
    if (books != null && books.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, i) {
            return _buildRows(books[i], i);
          });
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_books != null && _books.length > 0)
      _books = _books.where((a) => a.isFavorite == 1).toList();

    if (_books != null && _sort == "asc")
      _books.sort((a, b) => a.title.compareTo(b.title));
    if (_books != null && _sort == "desc")
      _books.sort((a, b) => b.title.compareTo(a.title));
    return Scaffold(
      backgroundColor: CustomColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Favorites'),
        backgroundColor: CustomColors.normal,
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha, color: Colors.white),
            onPressed: () {
              setState(() {
                _sort = (_sort == "asc" ? "desc" : "asc");
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: LoadingOverlay(
        color: CustomColors.normal,
        isLoading: _loading,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(children: <Widget>[_listBooks(_books)]),
          ),
        ),
      ),
    );
  }
}
// This function happens in the isolate.
void getBooks(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);

  messenger.listen((msg) async {
    String books = await Book.getJson();
    messenger.send(books);
  });
}