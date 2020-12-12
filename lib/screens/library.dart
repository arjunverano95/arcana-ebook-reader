import 'dart:convert';

import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:flutter/material.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Library extends StatelessWidget {
  Library();
  @override
  Widget build(BuildContext context) {
    return LibraryBody();
  }
}

class LibraryBody extends StatefulWidget {
  LibraryBody();
  @override
  LibraryBodyState createState() => LibraryBodyState();
}

class LibraryBodyState extends State<LibraryBody> {
  LibraryBodyState();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
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
    if (_books != null && _sort == "asc")
      _books.sort((a, b) => a.title.compareTo(b.title));
    if (_books != null && _sort == "desc")
      _books.sort((a, b) => b.title.compareTo(a.title));

    return Scaffold(
      key: _key,
      backgroundColor: CustomColors.background,
      endDrawer: Drawer(
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
                Icons.file_download,
                color: CustomColors.normal,
              ),
              title: Text(
                'Import books',
                style: TextStyle(color: CustomColors.textNormal, fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
                openImportDialog((bool loading) {
                  setState(() {
                    _loading = loading;
                  });
                }, _getBooks);
              },
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.scanner,
            //     color: CustomColors.normal,
            //   ),
            //   title: Text(
            //     'Scan books in directory',
            //     style: TextStyle(color: CustomColors.textNormal, fontSize: 15),
            //   ),
            //   onTap: () {},
            // ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: Text('Library'),
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
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _key.currentState.openEndDrawer();
            },
          )
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
        progressIndicator: CircularProgressIndicator(),
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

