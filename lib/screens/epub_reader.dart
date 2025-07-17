import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';

class EpubReaderScreen extends StatefulWidget {
  final Book book;
  final String filePath;

  const EpubReaderScreen({
    super.key,
    required this.book,
    required this.filePath,
  });

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  final epubController = EpubController();
  String? initialCfi;

  @override
  void initState() {
    super.initState();
    // Parse the last read locator if available
    if (widget.book.lastReadLocator.isNotEmpty) {
      try {
        final locatorData = jsonDecode(widget.book.lastReadLocator);
        // Extract CFI from the locator data
        initialCfi = locatorData['cfi'] ?? locatorData['href'];
      } catch (e) {
        print('Error parsing last read locator: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EpubViewer(
          epubSource: EpubSource.fromFile(File(widget.filePath)),
          epubController: epubController,
          initialCfi: initialCfi,
          displaySettings: EpubDisplaySettings(
            flow: EpubFlow.paginated,
            snap: true,
          ),
          onChaptersLoaded: (chapters) {
            print('Chapters loaded: ${chapters.length}');
          },
          onEpubLoaded: () async {
            print('EPUB loaded successfully');
          },
          onRelocated: (location) {
            // Save the current location
            _saveCurrentLocation(location);
          },
          onTextSelected: (selection) {
            print('Text selected');
          },
        ),
      ),
    );
  }

  void _saveCurrentLocation(EpubLocation location) {
    // Save the current location as a simple string for now
    final locatorData = {'progress': location.progress};

    DatabaseService.updateLastReadLocator(
      widget.book.id,
      jsonEncode(locatorData),
    ).whenComplete(() => env.bookstore.getBooks());
  }
}
