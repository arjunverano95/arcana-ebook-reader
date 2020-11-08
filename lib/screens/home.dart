import 'dart:convert';

import 'package:arcana_ebook_reader/screens/favorites.dart';
import 'package:arcana_ebook_reader/screens/library.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/importBooks.dart';
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
                            (book.title.length < 40)
                                ? book.title
                                : book.title.substring(0, 40) + "...",
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
                                child: Text('Delete',
                                    style: TextStyle(
                                      color: CustomColors.textNormal,
                                      fontSize: 15,
                                    )),
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

  Widget _recentRead(Book book) {
    if (book != null) {
      return InkWell(
        onTap: () {},
        child: Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(15),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 230,
                width: 169,
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
                  height: 250,
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
                              (book.title.length < 40)
                                  ? book.title
                                  : book.title.substring(0, 40) + "...",
                              style: TextStyle(
                                  color: CustomColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
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
                                  child: Text('Delete',
                                      style: TextStyle(
                                        color: CustomColors.textNormal,
                                        fontSize: 15,
                                      )),
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
                          fontSize: 15,
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
                                fontSize: 15,
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
                                    height: 30,
                                    width: 30,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.format_list_bulleted,
                                        size: 27,
                                      ),
                                      color: CustomColors.normal,
                                      onPressed: () {},
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        Icons.bookmark_border,
                                        size: 27,
                                      ),
                                      color: CustomColors.normal,
                                      onPressed: () {},
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        book.isFavorite == 1
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 27,
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
              _recentRead(recentRead),
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
              _recentAdded(recentAdded),
              Container(
                margin: EdgeInsets.only(top: 15, left: 15, right: 15),
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
                        openFileDialog((bool loading) {
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
