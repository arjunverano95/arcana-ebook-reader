import 'dart:convert';

import 'package:arcana_ebook_reader/screens/favorites.dart';
import 'package:arcana_ebook_reader/screens/library.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Home extends StatelessWidget {
  Home();

  @override
  Widget build(BuildContext context) {
    return HomeBody();
  }
}

class HomeBody extends StatefulWidget {
  HomeBody();
  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  HomeBodyState();
  bool _loading = true;
  List<Book> _books;
  final isolates = IsolateHandler();
  @override
  void initState() {
    super.initState();
    _getBooks();
  }

  Widget _buildRows(Book book, int index) {
    return BookTile(
      book: book,
      infoOnly: true,
    );
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

  Widget _recentRead(Book book) {
    if (book != null) {
      return BookTile(book: book, size: CoverSize.lg);
    } else {
      return Container();
    }
  }

  Widget _recentAdded(List<Book> books) {
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
    Book recentRead;
    List<Book> recentAdded;
    if (_books != null && _books.length > 0) {
      List<Book> recentReads = List.from(_books);
      recentReads.removeWhere((item) => item.lastRead == null);
      if (recentReads.length > 0) {
        recentReads.sort((a, b) => b.lastRead.compareTo(a.lastRead));
        recentRead = recentReads[0];
      }

      recentAdded = List.from(_books);
      recentAdded.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      recentAdded = recentAdded.take(7).toList();
    }
    return Scaffold(
      backgroundColor: CustomColors.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Arcana Ebook Reader',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: CustomColors.normal,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.library_books,
                color: CustomColors.normal,
              ),
              title: Text(
                'Library',
                style: TextStyle(color: CustomColors.textNormal, fontSize: 15),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => new Library(),
                  ),
                );

                _getBooks();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite_border,
                color: CustomColors.normal,
              ),
              title: Text(
                'Favorites',
                style: TextStyle(color: CustomColors.textNormal, fontSize: 15),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => new Favorites(),
                  ),
                );
                _getBooks();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: CustomColors.normal,
              ),
              title: Text(
                'Exit',
                style: TextStyle(color: CustomColors.textNormal, fontSize: 15),
              ),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: Text('Arcana Ebook Reader'),
        backgroundColor: CustomColors.normal,
      ),
      body: LoadingOverlay(
        color: CustomColors.normal,
        isLoading: _loading,
        progressIndicator: CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15),
                child: _recentRead(recentRead),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, left: 15, right: 15),
                padding: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 1,
                        color: CustomColors.normal,
                        style: BorderStyle.solid),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "RECENTLY ADDED",
                      style: TextStyle(
                        color: CustomColors.textNormal,
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: _recentAdded(recentAdded),
              ),
              Container(
                margin: EdgeInsets.all(15),
                decoration: (recentAdded != null && recentAdded.length > 0)
                    ? BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 1,
                              color: CustomColors.normal,
                              style: BorderStyle.solid),
                        ),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RaisedButton.icon(
                      color: CustomColors.normal,
                      onPressed: () => {
                        openImportDialog((bool loading) {
                          setState(() {
                            _loading = loading;
                          });
                        }, _getBooks)
                      },
                      icon: Icon(Icons.file_download, color: Colors.white),
                      label: Text(
                        "Import books",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
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
