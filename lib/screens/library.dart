import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/importBooks.dart';
import 'package:flutter/material.dart';
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
  double _progress = 0.0;
  List<Book> _books;
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
                child: book.coverImageData == null
                    ? Image.asset('assets/images/no_cover.jpg')
                    : Image.memory(book.coverImageData),
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
                            book.title,
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

  void _getBooks() {
    setState(() {
      _progress = null;
      _loading = true;
    });
    Book.get().then((value) => setState(() {
          _books = value;
          _progress = null;
          _loading = false;
        }));
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
              onTap: () => {
                openFileDialog((bool loading) {
                  setState(() {
                    _loading = loading;
                  });
                }, (double progress) {
                  setState(() {
                    _progress = progress;
                  });
                }, _getBooks)
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
        progressIndicator: _progress == null
            ? CircularProgressIndicator()
            : LinearProgressIndicator(
                value: _progress,
              ),
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
