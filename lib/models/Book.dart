import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:hive/hive.dart';

part 'Book.g.dart';

@HiveType(typeId: 1)
class Book extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;
  // int pagelength;
  // int progressPage;
  // int progressPercent;

  @HiveField(3)
  DateTime lastRead;

  @HiveField(4)
  DateTime addedDate;

  @HiveField(5)
  int isFavorite;

  @HiveField(6)
  String filePath;

  @HiveField(7)
  String fileType;

  @HiveField(8)
  int fileSize;

  @HiveField(9)
  String lastReadLocator;

  Book(
      {this.id,
      this.title,
      this.author,
      this.lastRead,
      this.addedDate,
      this.isFavorite,
      this.filePath,
      this.fileType,
      this.fileSize,
      this.lastReadLocator});

  factory Book.fromDto(BookDto b) {
    return Book(
        id: b.id,
        title: b.title,
        author: b.author,
        lastRead: b.lastRead,
        addedDate: b.addedDate,
        isFavorite: b.isFavorite,
        filePath: b.filePath,
        fileType: b.fileType,
        fileSize: b.fileSize,
        lastReadLocator: b.lastReadLocator);
  }
}
