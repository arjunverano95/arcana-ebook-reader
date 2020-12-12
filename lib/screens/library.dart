
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:isolate_handler/isolate_handler.dart';


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
  final isolates = IsolateHandler();
  @override
  void initState() {
    super.initState();
  }

  Widget _buildRows(Book book, int index) {
    return BookTile(book: book);
  }

  Widget _listBooks() {
    List<Book> books = List.from(env.bookstore.books);

    if (books != null && _sort == "asc")
      books.sort((a, b) => a.title.compareTo(b.title));
    if (books != null && _sort == "desc")
      books.sort((a, b) => b.title.compareTo(a.title));

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
                openImportDialog();
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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(children: [
            Observer(
              builder: (_) => _listBooks(),
            )
          ]),
        ),
      ),
    );
  }
}
