import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:arcana_ebook_reader/widgets/loading_overlay.dart';

class Library extends StatelessWidget {
  const Library({super.key});
  @override
  Widget build(BuildContext context) {
    return const LibraryBody();
  }
}

class LibraryBody extends StatefulWidget {
  const LibraryBody({super.key});
  @override
  LibraryBodyState createState() => LibraryBodyState();
}

class LibraryBodyState extends State<LibraryBody> {
  LibraryBodyState();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String _sort = "asc";
  @override
  void initState() {
    super.initState();
  }

  Widget _buildRows(BookDto book, int index) {
    return BookTile(book: book);
  }

  Widget _listBooks() {
    List<BookDto> books = List.from(env.bookstore.books);

    if (_sort == "asc") books.sort((a, b) => a.title.compareTo(b.title));
    if (_sort == "desc") books.sort((a, b) => b.title.compareTo(a.title));

    if (books.isNotEmpty) {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, i) {
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildRows(books[i], i),
                ),
              ),
            );
            //return _buildRows(books[i], i);
          });
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlay = LoadingOverlay.of(context);
    return SafeArea(
      child: Scaffold(
        key: _key,
        backgroundColor: CustomColors.background,
        endDrawer: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0.sp),
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: CustomColors.normal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 140.w,
                      width: 140.w,
                      child: Image.asset(
                          'assets/images/arcana_ebook_reader_transparent.png',
                          fit: BoxFit.fitWidth),
                    ),
                    Text(
                      'Arcana Ebook Reader',
                      style: TextStyle(color: Colors.white, fontSize: 30.sp),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.file_download,
                  color: CustomColors.normal,
                  size: 44.sp,
                ),
                title: Text(
                  'Import books',
                  style: TextStyle(
                      color: CustomColors.textNormal, fontSize: 28.sp),
                ),
                onTap: () {
                  env.navigation.pop();
                  overlay.during(showImportDialog());
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.scanner,
              //     color: CustomColors.normal,
              //   ),
              //   title: Text(
              //     'Scan books in directory',
              //     style: TextStyle(color: CustomColors.textNormal, fontSize: 28.sp),
              //   ),
              //   onTap: () {},
              // ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          title: Text('Library',
              style: TextStyle(color: Colors.white, fontSize: 30.sp)),
          actions: [
            IconButton(
                icon:
                    Icon(Icons.sort_by_alpha, color: Colors.white, size: 44.sp),
                onPressed: () => setState(() {
                      _sort = (_sort == "asc" ? "desc" : "asc");
                    })),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white, size: 44.sp),
              onPressed: () {},
            ),
            IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 44.sp),
                onPressed: () => _key.currentState?.openEndDrawer())
          ],
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 44.sp),
              onPressed: () => env.navigation.pop()),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(30.sp),
          child: ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Column(children: [
              Observer(
                builder: (_) => _listBooks(),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
