import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
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
          var book = await DatabaseService.getBook(toRead);
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

Future<void> showModernImportDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 400.w),
          decoration: BoxDecoration(
            color: CustomColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: CustomColors.blackWithOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const ImportDialogContent(),
        ),
      );
    },
  );
}

class ImportDialogContent extends StatefulWidget {
  const ImportDialogContent({super.key});

  @override
  State<ImportDialogContent> createState() => _ImportDialogContentState();
}

class _ImportDialogContentState extends State<ImportDialogContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: CustomColors.primaryWithOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Image.asset(
                          'assets/images/arcana_ebook_reader.png',
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import Books',
                              style: TextStyle(
                                color: CustomColors.textPrimary,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Add ebooks to your library',
                              style: TextStyle(
                                color: CustomColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: CustomColors.textSecondary,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Import options
                  _buildImportOption(
                    icon: Icons.file_upload_rounded,
                    title: 'Import EPUB Files',
                    subtitle: 'Select one or more EPUB files from your device',
                    onTap: () => _handleFileImport(context),
                  ),
                  SizedBox(height: 12.h),
                  _buildImportOption(
                    icon: Icons.folder_open_rounded,
                    title: 'Browse Folders',
                    subtitle: 'Scan a folder for supported ebook files',
                    onTap: () => _handleFolderImport(context),
                    isEnabled: false, // Future feature
                  ),
                  SizedBox(height: 12.h),
                  _buildImportOption(
                    icon: Icons.cloud_download_rounded,
                    title: 'Download from URL',
                    subtitle: 'Import ebooks directly from a web URL',
                    onTap: () => _handleUrlImport(context),
                    isEnabled: false, // Future feature
                  ),

                  SizedBox(height: 24.h),

                  // Support info
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: CustomColors.infoWithOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: CustomColors.infoWithOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: CustomColors.info,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supported Formats',
                                style: TextStyle(
                                  color: CustomColors.textPrimary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Currently supporting EPUB format. More formats coming soon!',
                                style: TextStyle(
                                  color: CustomColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isEnabled
              ? CustomColors.backgroundSecondary
              : CustomColors.backgroundSecondaryWithOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isEnabled
                ? CustomColors.divider
                : CustomColors.dividerWithOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isEnabled
                    ? CustomColors.primaryWithOpacity(0.1)
                    : CustomColors.textTertiaryWithOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isEnabled
                    ? CustomColors.primary
                    : CustomColors.textTertiary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isEnabled
                          ? CustomColors.textPrimary
                          : CustomColors.textTertiary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isEnabled
                          ? CustomColors.textSecondary
                          : CustomColors.textTertiary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: CustomColors.warningWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    color: CustomColors.warning,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: CustomColors.textTertiary,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFileImport(BuildContext context) async {
    Navigator.of(context).pop();

    if (await Permission.storage.request().isGranted) {
      var result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Show import progress dialog
        if (context.mounted) {
          _showImportProgress(context, result.files);
        }
      }
    }
  }

  Future<void> _handleFolderImport(BuildContext context) async {
    // Future implementation
    Navigator.of(context).pop();
  }

  Future<void> _handleUrlImport(BuildContext context) async {
    // Future implementation
    Navigator.of(context).pop();
  }

  void _showImportProgress(BuildContext context, List<PlatformFile> files) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImportProgressDialog(files: files),
    );
  }
}

class ImportProgressDialog extends StatefulWidget {
  final List<PlatformFile> files;

  const ImportProgressDialog({super.key, required this.files});

  @override
  State<ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<ImportProgressDialog> {
  int _currentIndex = 0;
  bool _isComplete = false;
  String _currentFileName = '';

  @override
  void initState() {
    super.initState();
    _importFiles();
  }

  Future<void> _importFiles() async {
    for (int i = 0; i < widget.files.length; i++) {
      setState(() {
        _currentIndex = i;
        _currentFileName = widget.files[i].name;
      });

      await _importBook(widget.files[i]);
    }

    setState(() {
      _isComplete = true;
    });

    env.bookstore.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.files.isEmpty
        ? 1.0
        : (_currentIndex + 1) / widget.files.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 350.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: CustomColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isComplete) ...[
              Icon(
                Icons.check_circle_rounded,
                color: CustomColors.success,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Import Complete!',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${widget.files.length} books imported successfully',
                style: TextStyle(
                  color: CustomColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Done'),
              ),
            ] else ...[
              CircularProgressIndicator(
                value: progress,
                color: CustomColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 16.h),
              Text(
                'Importing Books...',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Book ${_currentIndex + 1} of ${widget.files.length}',
                style: TextStyle(
                  color: CustomColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _currentFileName,
                style: TextStyle(
                  color: CustomColors.textTertiary,
                  fontSize: 12.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
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

      Book newBook = Book(
        id: uKey,
        title: metadata?.title ?? file.name.replaceAll('.epub', ''),
        author: metadata?.author ?? 'Unknown Author',
        lastRead: null,
        addedDate: DateTime.now(),
        isFavorite: 0,
        filePath: filePath,
        fileType: fileExt,
        fileSize: fileSize,
        lastReadLocator: '',
        coverImageData:
            metadata?.coverData ??
            await DatabaseService.getCoverImageData(filePath),
        totalPages: null,
        currentPage: null,
        progressPercent: null,
        description: null,
        isbn: null,
        publisher: null,
        publishDate: null,
        language: null,
        readingTime: null,
      );

      await DatabaseService.addBook(newBook);
      return newBook.id;
    } catch (e) {
      developer.log('Error importing EPUB: $e');
      return null;
    }
  }
  return null;
}
