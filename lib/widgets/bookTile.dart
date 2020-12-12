import 'package:arcana_ebook_reader/util/context.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    Book book = widget.book;
    CoverSize size = widget.size;
    bool infoOnly = widget.infoOnly;

    if (infoOnly == null) infoOnly = false;
    if (size == null) size = CoverSize.md;

    double coverWidth = 0;
    double coverHeight = 0;
    double containerHeight = 0;
    if (size == CoverSize.md) {
      coverWidth = 110.4;
      coverHeight = 150;
      containerHeight = 150;
    } else if (size == CoverSize.lg) {
      coverWidth = 169;
      coverHeight = 230;
      containerHeight = 230;
    }

    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: 15, left: 15, right: 15),
        padding: EdgeInsets.all(15),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: coverHeight,
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
                height: containerHeight,
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
                                // TODO Refresh list
                                // Book.delete(book.id)
                                //     .then((value) => _getBooks());
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
                          Visibility(
                            visible: !infoOnly,
                            child: Container(
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
                                        // TODO Refresh list
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
