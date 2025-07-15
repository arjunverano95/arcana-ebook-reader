import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  DateTimeColumn get lastRead => dateTime().nullable()();
  DateTimeColumn get addedDate => dateTime()();
  IntColumn get isFavorite => integer()();
  TextColumn get filePath => text()();
  TextColumn get fileType => text()();
  IntColumn get fileSize => integer()();
  TextColumn get lastReadLocator => text()();
  BlobColumn get coverImageData => blob()();
  IntColumn get totalPages => integer().nullable()();
  IntColumn get currentPage => integer().nullable()();
  RealColumn get progressPercent => real().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get publishDate => dateTime().nullable()();
  TextColumn get language => text().nullable()();
  IntColumn get readingTime => integer().nullable()(); // in minutes

  @override
  Set<Column> get primaryKey => {id};
}

class ReadingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text().references(Books, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get pagesRead => integer()();
  IntColumn get durationMinutes => integer()();
  TextColumn get notes => text().nullable()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get title => text()();
  TextColumn get locator => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get notes => text().nullable()();
  IntColumn get pageNumber => integer().nullable()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();
}

class BookTags extends Table {
  TextColumn get bookId => text().references(Books, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

@DriftDatabase(tables: [Books, ReadingSessions, Bookmarks, Tags, BookTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
    );
  }

  // Book operations
  Future<List<Book>> getAllBooks() => select(books).get();

  Future<List<Book>> getFavoriteBooks() =>
      (select(books)..where((b) => b.isFavorite.equals(1))).get();

  Future<List<Book>> getRecentlyReadBooks({int limit = 10}) =>
      (select(books)
            ..where((b) => b.lastRead.isNotNull())
            ..orderBy([(b) => OrderingTerm.desc(b.lastRead)])
            ..limit(limit))
          .get();

  Future<Book?> getBook(String id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<bool> bookExists(String id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull().then(
        (book) => book != null,
      );

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(BooksCompanion book) => update(books).replace(book);

  Future<int> deleteBook(String id) =>
      (delete(books)..where((b) => b.id.equals(id))).go();

  Future<int> toggleFavorite(String id) =>
      (update(books)..where((b) => b.id.equals(id))).write(
        BooksCompanion(isFavorite: const Value(1)),
      );

  Future<int> updateLastRead(String id) =>
      (update(books)..where((b) => b.id.equals(id))).write(
        BooksCompanion(lastRead: Value(DateTime.now())),
      );

  Future<int> updateReadingProgress(
    String id,
    int currentPage,
    double progressPercent,
  ) => (update(books)..where((b) => b.id.equals(id))).write(
    BooksCompanion(
      currentPage: Value(currentPage),
      progressPercent: Value(progressPercent),
      lastRead: Value(DateTime.now()),
    ),
  );

  Future<int> updateLastReadLocator(String id, String locator) =>
      (update(books)..where((b) => b.id.equals(id))).write(
        BooksCompanion(lastReadLocator: Value(locator)),
      );

  // Reading session operations
  Future<int> insertReadingSession(ReadingSessionsCompanion session) =>
      into(readingSessions).insert(session);

  Future<List<ReadingSession>> getReadingSessions(String bookId) =>
      (select(readingSessions)
            ..where((s) => s.bookId.equals(bookId))
            ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
          .get();

  Future<ReadingSession?> getCurrentSession(String bookId) =>
      (select(readingSessions)
            ..where((s) => s.bookId.equals(bookId) & s.endTime.isNull()))
          .getSingleOrNull();

  Future<int> endReadingSession(
    int sessionId,
    DateTime endTime,
    int pagesRead,
    int durationMinutes,
  ) => (update(readingSessions)..where((s) => s.id.equals(sessionId))).write(
    ReadingSessionsCompanion(
      endTime: Value(endTime),
      pagesRead: Value(pagesRead),
      durationMinutes: Value(durationMinutes),
    ),
  );

  // Bookmark operations
  Future<int> insertBookmark(BookmarksCompanion bookmark) =>
      into(bookmarks).insert(bookmark);

  Future<List<Bookmark>> getBookmarks(String bookId) =>
      (select(bookmarks)
            ..where((b) => b.bookId.equals(bookId))
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
          .get();

  Future<int> deleteBookmark(int bookmarkId) =>
      (delete(bookmarks)..where((b) => b.id.equals(bookmarkId))).go();

  Future<int> updateBookmark(int bookmarkId, BookmarksCompanion bookmark) =>
      (update(bookmarks)..where((b) => b.id.equals(bookmarkId)))
          .replace(bookmark)
          .then((value) => 1); // Always return 1 for success

  // Tag operations
  Future<List<Tag>> getAllTags() => select(tags).get();

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<int> deleteTag(int tagId) =>
      (delete(tags)..where((t) => t.id.equals(tagId))).go();

  Future<List<Tag>> getBookTags(String bookId) =>
      (select(tags)
            ..join([innerJoin(bookTags, bookTags.tagId.equalsExp(tags.id))]))
          .get()
          .then((result) => result.toList());

  Future<int> addTagToBook(String bookId, int tagId) => into(
    bookTags,
  ).insert(BookTagsCompanion(bookId: Value(bookId), tagId: Value(tagId)));

  Future<int> removeTagFromBook(String bookId, int tagId) => (delete(
    bookTags,
  )..where((bt) => bt.bookId.equals(bookId) & bt.tagId.equals(tagId))).go();

  // Search operations
  Future<List<Book>> searchBooks(String query) => (select(
    books,
  )..where((b) => b.title.contains(query) | b.author.contains(query))).get();

  Future<List<Book>> getBooksByTag(int tagId) =>
      (select(books)
            ..join([innerJoin(bookTags, bookTags.bookId.equalsExp(books.id))]))
          .get()
          .then((result) => result.toList());

  // Statistics
  Future<int> getTotalBooks() =>
      (select(books)).get().then((books) => books.length);

  Future<int> getTotalReadingTime() =>
      (select(
        readingSessions,
      )..where((s) => s.durationMinutes.isNotNull())).get().then(
        (sessions) => sessions.fold<int>(
          0,
          (sum, session) => sum + (session.durationMinutes),
        ),
      );

  Future<List<Book>> getMostReadBooks({int limit = 10}) =>
      (select(books)
            ..where((b) => b.readingTime.isNotNull())
            ..orderBy([(b) => OrderingTerm.desc(b.readingTime)])
            ..limit(limit))
          .get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'arcana_ebook_reader.db'));
    return NativeDatabase.createInBackground(file);
  });
}
