import 'package:arcana_ebook_reader/models/Book.dart';

class BookDto {
  String id;
  String title;
  String author;
  // int pagelength;
  // int progressPage;
  // int progressPercent;
  DateTime? lastRead;
  DateTime addedDate;
  int isFavorite;
  String filePath;
  String fileType;
  int fileSize;
  String lastReadLocator;
  List<int> coverImageData;

  BookDto()
      : id = "",
        title = "",
        author = "",
        lastRead = null,
        addedDate = DateTime.now(),
        isFavorite = 0,
        filePath = "",
        fileType = "",
        fileSize = 0,
        lastReadLocator = "",
        coverImageData = [];

  BookDto.fromBook(Book b)
      : id = b.id,
        title = b.title,
        author = b.author,
        lastRead = b.lastRead,
        addedDate = b.addedDate,
        isFavorite = b.isFavorite,
        filePath = b.filePath,
        fileType = b.fileType,
        fileSize = b.fileSize,
        lastReadLocator = b.lastReadLocator,
        coverImageData = b.coverImageData;
}
