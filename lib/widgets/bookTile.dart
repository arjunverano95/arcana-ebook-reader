import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isolate_handler/isolate_handler.dart';

enum CoverSize { md, lg } //sm, xl

class BookTile extends StatefulWidget {
  final Book book;
  final CoverSize size;
  final bool infoOnly;

  BookTile({@required this.book, this.size, this.infoOnly});

  @override
  _BookTileState createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  final isolates = IsolateHandler();
  @override
  Widget build(BuildContext context) {
    Book book = widget.book;
    CoverSize size = widget.size;
    bool infoOnly = widget.infoOnly;

    if (infoOnly == null) infoOnly = false;
    if (size == null) size = CoverSize.md;

    double coverWidth = 0;
    double containerHeight = 0;
    if (size == CoverSize.md) {
      coverWidth = 220.w;
      containerHeight = 290.w;
    } else if (size == CoverSize.lg) {
      coverWidth = 300.w;
      containerHeight = 410.w;
      // coverWidth = 169;
      // coverHeight = 230;
      // containerHeight = 230;
    }
    Image coverImage = Image.asset('assets/images/no_cover.jpg',
        fit: BoxFit.fitWidth, key: Key("cv_loading")); //TODO loading image

    if (book.coverImageData != null) {
      coverImage = Image.memory(book.coverImageData,
          fit: BoxFit.fitWidth, key: Key("cv_" + book.id));
    }

    void setCoverImage(List<int> bytes) {
      // We will no longer be needing the isolate, let's dispose of it.
      isolates.kill("getCoverImage_" + book.id);
      book.setCoverImageData(bytes);
      setState(() {
        coverImage = bytes == null
            ? Image.asset('assets/images/no_cover.jpg',
                fit: BoxFit.fitWidth, key: Key("cv_none"))
            : Image.memory(bytes,
                fit: BoxFit.fitWidth, key: Key("cv_" + book.id + "_new"));
      });
    }

    if (book.coverImageData == null) {
      isolates.spawn<List<int>>(getCoverImage,
          name: "getCoverImage_" + book.id,
          onReceive: setCoverImage,
          onInitialized: () =>
              isolates.send(book.filePath, to: "getCoverImage_" + book.id));
    }

    return InkWell(
      onTap: () => readEbook(book),
      child: Container(
        padding: EdgeInsets.all(30.sp),
        margin: EdgeInsets.only(bottom: 30.sp),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              // height: coverHeight,
              width: coverWidth,
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  // transitionBuilder:
                  //     (Widget child, Animation<double> animation) {
                  //   return ScaleTransition(child: child, scale: animation);
                  // },
                  child: coverImage,
                ),

                // FutureBuilder(
                //   future: book.getCoverImageData(),
                //   builder: (BuildContext context,
                //       AsyncSnapshot<List<int>> snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting &&
                //         snapshot.hasData == false) {
                //       return Image.asset('assets/images/no_cover.jpg',
                //           fit: BoxFit.fitWidth);
                //     } else {
                //       var image = snapshot.data;
                //       if (image == null) {
                //         return Image.asset('assets/images/no_cover.jpg',
                //             fit: BoxFit.fitWidth);
                //       } else {
                //         return Image.memory(image, fit: BoxFit.fitWidth);
                //       }
                //     }
                //   },
                // ),
              ),
            ),
            Expanded(
              child: Container(
                height: containerHeight,
                padding: EdgeInsets.only(left: 30.sp),
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
                                fontSize: 30.sp),
                          ),
                        ),
                        SizedBox(
                          height: 50.w,
                          width: 50.w,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.all(0.sp),
                            icon: Icon(
                              Icons.more_vert,
                              size: 40.sp,
                            ),
                            onSelected: (String result) {
                              if (result == "Delete") {
                                Book.delete(book.id)
                                    .then((value) => env.bookstore.getBooks());
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: "Delete",
                                child: Text('Delete',
                                    style: TextStyle(
                                      color: CustomColors.textNormal,
                                      fontSize: 28.sp,
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
                        fontSize: 25.sp,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            book.fileType.toUpperCase() +
                                ", " +
                                ((book.fileSize / 1000)).toStringAsFixed(1) +
                                "MB",
                            style: TextStyle(
                              color: CustomColors.textHighlight,
                              fontSize: 24.sp,
                            ),
                          ),
                          Visibility(
                            visible: !infoOnly,
                            child: Container(
                              padding: EdgeInsets.only(top: 10.sp),
                              margin: EdgeInsets.only(top: 10.sp),
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
                                    height: 52.w,
                                    width: 52.w,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0.sp),
                                      icon: Icon(
                                        Icons.format_list_bulleted,
                                        size: 44.sp,
                                      ),
                                      color: CustomColors.normal,
                                      onPressed: () {},
                                    ),
                                  ),
                                  Container(
                                    width: 20.w,
                                  ),
                                  SizedBox(
                                    height: 52.w,
                                    width: 52.w,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0.sp),
                                      icon: Icon(
                                        Icons.bookmark_border,
                                        size: 44.sp,
                                      ),
                                      color: CustomColors.normal,
                                      onPressed: () {},
                                    ),
                                  ),
                                  Container(
                                    width: 20.w,
                                  ),
                                  SizedBox(
                                    height: 52.w,
                                    width: 52.w,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0.sp),
                                      icon: Icon(
                                        book.isFavorite == 1
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 44.sp,
                                      ),
                                      color: book.isFavorite == 1
                                          ? Colors.red
                                          : CustomColors.normal,
                                      onPressed: () {
                                        book.updateFavorite().then((value) =>
                                            env.bookstore.getBooks());
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
                          )
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
}

// This function happens in the isolate.
void getCoverImage(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  // Triggered every time data is received from the main isolate.
  messenger.listen((filePath) {
    // Add one to the count and send the new value back to the main
    // isolate.
    Book.getCoverImageData(filePath).then((value) => messenger.send(value));
  });
}
