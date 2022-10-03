import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:arcana_ebook_reader/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:arcana_ebook_reader/extension.dart';

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

class HomeBodyState extends State<HomeBody>
    with SingleTickerProviderStateMixin {
  HomeBodyState();
  late AnimationController _recentReadAnimationController;
  late Animation<double> _recentReadAnimation;

  @override
  void initState() {
    super.initState();
    _recentReadAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _recentReadAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_recentReadAnimationController);
  }

  Widget _buildRows(BookDto book, int index) {
    return BookTile(
      book: book,
      infoOnly: true,
    );
  }

  Widget _recentRead() {
    BookDto? recentRead;
    if (env.bookstore.books.length > 0) {
      List<BookDto> recentReads =
          List.from(env.bookstore.books.where((item) => item.lastRead != null));

      if (recentReads.length > 0) {
        recentReads.sort((a, b) => b.lastRead.compareToWithNull(a.lastRead));
        recentRead = recentReads[0];
      }
    }

    if (recentRead != null) {
      return BookTile(book: recentRead, size: CoverSize.lg);
    } else {
      return Container();
    }
  }

  Widget _recentAdded() {
    List<BookDto> recentAdded = [];
    if (env.bookstore.books.length > 0) {
      recentAdded = List.from(env.bookstore.books);
      recentAdded.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      recentAdded = recentAdded.take(7).toList();
    }

    if (recentAdded.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentAdded.length,
          itemBuilder: (context, i) {
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildRows(recentAdded[i], i),
                ),
              ),
            );
          });
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    _recentReadAnimationController.forward();
    final overlay = LoadingOverlay.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.background,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0.sp),
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
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
                decoration: BoxDecoration(
                  color: CustomColors.normal,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: CustomColors.normal,
                  size: 44.sp,
                ),
                title: Text(
                  'Library',
                  style: TextStyle(
                      color: CustomColors.textNormal, fontSize: 28.sp),
                ),
                onTap: () async {
                  env.navigation.popAndNavigate('library');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.favorite_border,
                  color: CustomColors.normal,
                  size: 44.sp,
                ),
                title: Text(
                  'Favorites',
                  style: TextStyle(
                      color: CustomColors.textNormal, fontSize: 28.sp),
                ),
                onTap: () async {
                  env.navigation.popAndNavigate('favorites');
                },
              ),
              ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: CustomColors.normal,
                    size: 44.sp,
                  ),
                  title: Text(
                    'Exit',
                    style: TextStyle(
                        color: CustomColors.textNormal, fontSize: 28.sp),
                  ),
                  onTap: () => SystemNavigator.pop()),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          title: Text('Arcana Ebook Reader',
              style: TextStyle(color: Colors.white, fontSize: 30.sp)),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(30.sp),
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(children: <Widget>[
              Container(
                child: Observer(
                  builder: (_) => FadeTransition(
                    opacity: _recentReadAnimation,
                    child: _recentRead(),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10.sp),
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
                        fontSize: 28.sp,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 30.sp),
                child: Observer(builder: (_) => _recentAdded()),
              ),
              Observer(
                builder: (_) => Container(
                  decoration: (env.bookstore.books.length > 0)
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
                      ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                CustomColors.normal)),
                        onPressed: () => overlay.during(showImportDialog()),
                        icon: Icon(Icons.file_download,
                            color: Colors.white, size: 44.sp),
                        label: Text(
                          "Import books",
                          style:
                              TextStyle(color: Colors.white, fontSize: 28.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
