import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:archive/archive.dart';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/bookLibrary.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';

Future<void> showImportDialog() async {
  if (await Permission.storage.request().isGranted) {
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result!.files.isNotEmpty) {
      if (result.files.length == 1) {
        var file = result.files[0];
        var toRead = await _importBook(
          file,
        ).whenComplete(() => env.bookstore.getBooks());

        if (toRead != null) {
          var book = await BookLibrary.get(toRead);
          if (book != null) readEbook(book);
        }
      } else {
        await Future.wait(
          result.files.map((file) async {
            await _importBook(file);
          }),
        ).whenComplete(() => env.bookstore.getBooks());
      }
    }
  }
}

class EpubMetadata {
  final String title;
  final String author;
  final List<int>? coverData;

  EpubMetadata({required this.title, required this.author, this.coverData});
}

Future<EpubMetadata?> _extractEpubMetadata(String filePath) async {
  try {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    // Parse EPUB as ZIP
    final archive = ZipDecoder().decodeBytes(bytes);

    // Find container.xml
    final containerEntry = archive.findFile('META-INF/container.xml');
    if (containerEntry == null) return null;

    final containerXml = utf8.decode(containerEntry.content as List<int>);

    // Extract OPF path
    final opfMatch = RegExp(
      r'<rootfile[^>]*full-path="([^"]*)"',
    ).firstMatch(containerXml);
    if (opfMatch == null) return null;

    final opfPath = opfMatch.group(1);
    if (opfPath == null) return null;

    final opfEntry = archive.findFile(opfPath);
    if (opfEntry == null) return null;

    final opfXml = utf8.decode(opfEntry.content as List<int>);

    // Extract title and author
    String title = '';
    String author = '';

    // Look for title in various possible locations
    final titleMatch = RegExp(
      r'<dc:title[^>]*>([^<]*)</dc:title>',
    ).firstMatch(opfXml);
    if (titleMatch != null) {
      title = titleMatch.group(1)?.trim() ?? '';
    }

    final authorMatch = RegExp(
      r'<dc:creator[^>]*>([^<]*)</dc:creator>',
    ).firstMatch(opfXml);
    if (authorMatch != null) {
      author = authorMatch.group(1)?.trim() ?? '';
    }

    // Try to extract cover image
    List<int>? coverData;
    final coverMatch = RegExp(
      r'<meta[^>]*name="cover"[^>]*content="([^"]*)"',
    ).firstMatch(opfXml);
    if (coverMatch != null) {
      final coverId = coverMatch.group(1);
      if (coverId != null) {
        final coverItemMatch = RegExp(
          r'<item[^>]*id="$coverId"[^>]*href="([^"]*)"',
        ).firstMatch(opfXml);
        if (coverItemMatch != null) {
          final coverPath = coverItemMatch.group(1);
          if (coverPath != null) {
            final coverEntry = archive.findFile(coverPath);
            if (coverEntry != null) {
              coverData = coverEntry.content as List<int>;
            }
          }
        }
      }
    }

    return EpubMetadata(
      title: title.isNotEmpty ? title : 'Unknown Title',
      author: author.isNotEmpty ? author : 'Unknown Author',
      coverData: coverData,
    );
  } catch (e) {
    developer.log('Error extracting EPUB metadata: $e');
    return null;
  }
}

Future<String?> _importBook(PlatformFile file) async {
  String filePath = file.path ?? '';
  int fileSize = file.size;
  String fileExt = file.extension ?? ''.toLowerCase();

  if (fileExt == "epub") {
    try {
      // Extract metadata from EPUB
      final metadata = await _extractEpubMetadata(filePath);

      String uKey = const Uuid().v1();

      BookDto newBook = BookDto();
      newBook.id = uKey;
      newBook.title = metadata?.title ?? file.name.replaceAll('.epub', '');
      newBook.author = metadata?.author ?? 'Unknown Author';
      newBook.addedDate = DateTime.now();
      newBook.isFavorite = 0;
      newBook.filePath = filePath;
      newBook.fileSize = fileSize;
      newBook.fileType = fileExt;

      // Use extracted cover or default
      if (metadata?.coverData != null) {
        newBook.coverImageData = metadata!.coverData!;
      } else {
        newBook.coverImageData = await BookLibrary.getCoverImageData(filePath);
      }

      await BookLibrary.add(newBook);
      return newBook.id;
    } catch (e) {
      developer.log('Error importing EPUB: $e');
      return null;
    }
  }
  return null;
}
