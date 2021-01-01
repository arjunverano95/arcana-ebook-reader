import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  @override
  void initState() {
    super.initState();
  }

  Widget _buildRows(Book book, int index) {
    return BookTile(
      book: book,
    );
  }

  Widget _listBooks() {
    List<Book> books = List.from(env.bookstore.books);
    if (books != null && books.length > 0)
      books = books.where((a) => a.isFavorite == 1).toList();

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
      backgroundColor: CustomColors.background,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Favorites',
            style: TextStyle(color: Colors.white, fontSize: 30.sp)),
        actions: [
          IconButton(
              icon: Icon(Icons.sort_by_alpha, color: Colors.white, size: 44.sp),
              onPressed: () => setState(() {
                    _sort = (_sort == "asc" ? "desc" : "asc");
                  })),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 44.sp),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 44.sp),
            onPressed: () => env.navigation.pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(30.sp),
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
