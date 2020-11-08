import 'dart:convert';

import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
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
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 15, right: 15),
        padding: EdgeInsets.all(15),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 110.4,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRect(
                child: FutureBuilder(
                  future: book.getCoverImageData(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        snapshot.hasData == false) {
                      return Image.asset('assets/images/no_cover.jpg');
                    } else {
                      var image = snapshot.data;
                      if (image == null) {
                        return Image.asset('assets/images/no_cover.jpg');
                      } else {
                        return Image.memory(image);
                      }
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 150,
                padding: EdgeInsets.only(left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (book.title.length < 40)? book.title : book.title.substring(0,40)+ "...",
                            style: TextStyle(
                                color: CustomColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                        ),
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.more_vert,
                              size: 22,
                            ),
                            onSelected: (String result) {
                              if (result == "Delete") {
                                Book.delete(book.id)
                                    .then((value) => _getBooks());
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: "Delete",
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: CustomColors.textNormal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: CustomColors.textGray,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Page " +
                                book.progressPage.toString() +
                                " of " +
                                book.pagelength.toString() +
                                " (" +
                                book.progressPercent.toString() +
                                "%)",
                            style: TextStyle(
                              color: CustomColors.textHighlight,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 5),
                            margin: EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 1,
                                    color: CustomColors.normal,
                                    style: BorderStyle.solid),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 27,
                                  width: 27,
                                  child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.format_list_bulleted,
                                      size: 24,
                                    ),
                                    color: CustomColors.normal,
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 27,
                                  width: 27,
                                  child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.bookmark_border,
                                      size: 24,
                                    ),
                                    color: CustomColors.normal,
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  width: 10,
                                ),
                                SizedBox(
                                  height: 27,
                                  width: 27,
                                  child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      book.isFavorite == 1
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 24,
                                    ),
                                    color: book.isFavorite == 1
                                        ? Colors.red
                                        : CustomColors.normal,
                                    onPressed: () {
                                      book.updateFavorite();
                                      setState(() {
                                        book.isFavorite =
                                            book.isFavorite == 1 ? 0 : 1;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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