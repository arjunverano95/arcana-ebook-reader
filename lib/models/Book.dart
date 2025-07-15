class Book {
  final String id;
  final String title;
  final String author;
  final DateTime? lastRead;
  final DateTime addedDate;
  final int isFavorite;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String lastReadLocator;
  final List<int> coverImageData;
  final int? totalPages;
  final int? currentPage;
  final double? progressPercent;
  final String? description;
  final String? isbn;
  final String? publisher;
  final DateTime? publishDate;
  final String? language;
  final int? readingTime;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.lastRead,
    required this.addedDate,
    required this.isFavorite,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.lastReadLocator,
    required this.coverImageData,
    this.totalPages,
    this.currentPage,
    this.progressPercent,
    this.description,
    this.isbn,
    this.publisher,
    this.publishDate,
    this.language,
    this.readingTime,
  });

  factory Book.fromData(Map<String, dynamic> data) {
    return Book(
      id: data['id'] as String,
      title: data['title'] as String,
      author: data['author'] as String,
      lastRead: data['lastRead'] as DateTime?,
      addedDate: data['addedDate'] as DateTime,
      isFavorite: data['isFavorite'] as int,
      filePath: data['filePath'] as String,
      fileType: data['fileType'] as String,
      fileSize: data['fileSize'] as int,
      lastReadLocator: data['lastReadLocator'] as String,
      coverImageData: data['coverImageData'] as List<int>,
      totalPages: data['totalPages'] as int?,
      currentPage: data['currentPage'] as int?,
      progressPercent: data['progressPercent'] as double?,
      description: data['description'] as String?,
      isbn: data['isbn'] as String?,
      publisher: data['publisher'] as String?,
      publishDate: data['publishDate'] as DateTime?,
      language: data['language'] as String?,
      readingTime: data['readingTime'] as int?,
    );
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    DateTime? lastRead,
    DateTime? addedDate,
    int? isFavorite,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? lastReadLocator,
    List<int>? coverImageData,
    int? totalPages,
    int? currentPage,
    double? progressPercent,
    String? description,
    String? isbn,
    String? publisher,
    DateTime? publishDate,
    String? language,
    int? readingTime,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      lastRead: lastRead ?? this.lastRead,
      addedDate: addedDate ?? this.addedDate,
      isFavorite: isFavorite ?? this.isFavorite,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      lastReadLocator: lastReadLocator ?? this.lastReadLocator,
      coverImageData: coverImageData ?? this.coverImageData,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      progressPercent: progressPercent ?? this.progressPercent,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publishDate: publishDate ?? this.publishDate,
      language: language ?? this.language,
      readingTime: readingTime ?? this.readingTime,
    );
  }

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, lastRead: $lastRead, addedDate: $addedDate, isFavorite: $isFavorite, filePath: $filePath, fileType: $fileType, fileSize: $fileSize, lastReadLocator: $lastReadLocator, coverImageData: ${coverImageData.length} bytes, totalPages: $totalPages, currentPage: $currentPage, progressPercent: $progressPercent, description: $description, isbn: $isbn, publisher: $publisher, publishDate: $publishDate, language: $language, readingTime: $readingTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.lastRead == lastRead &&
        other.addedDate == addedDate &&
        other.isFavorite == isFavorite &&
        other.filePath == filePath &&
        other.fileType == fileType &&
        other.fileSize == fileSize &&
        other.lastReadLocator == lastReadLocator &&
        other.coverImageData.length == coverImageData.length &&
        other.totalPages == totalPages &&
        other.currentPage == currentPage &&
        other.progressPercent == progressPercent &&
        other.description == description &&
        other.isbn == isbn &&
        other.publisher == publisher &&
        other.publishDate == publishDate &&
        other.language == language &&
        other.readingTime == readingTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        lastRead.hashCode ^
        addedDate.hashCode ^
        isFavorite.hashCode ^
        filePath.hashCode ^
        fileType.hashCode ^
        fileSize.hashCode ^
        lastReadLocator.hashCode ^
        coverImageData.length.hashCode ^
        totalPages.hashCode ^
        currentPage.hashCode ^
        progressPercent.hashCode ^
        description.hashCode ^
        isbn.hashCode ^
        publisher.hashCode ^
        publishDate.hashCode ^
        language.hashCode ^
        readingTime.hashCode;
  }
}
