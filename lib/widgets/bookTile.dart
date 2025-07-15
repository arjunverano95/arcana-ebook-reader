import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/services/database_service.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/ebookReader.dart';

enum CoverSize { md, lg }

class BookTile extends StatefulWidget {
  final Book book;
  final CoverSize size;
  final bool infoOnly;

  const BookTile({
    super.key,
    required this.book,
    this.size = CoverSize.md,
    this.infoOnly = false,
  });

  @override
  BookTileState createState() => BookTileState();
}

class BookTileState extends State<BookTile> {
  @override
  Widget build(BuildContext context) {
    Book book = widget.book;
    CoverSize size = widget.size;
    bool infoOnly = widget.infoOnly;

    if (size == CoverSize.lg) {
      return _buildLargeCard(book, infoOnly);
    } else {
      return _buildCompactCard(book, infoOnly);
    }
  }

  Widget _buildLargeCard(Book book, bool infoOnly) {
    return InkWell(
      onTap: () => readEbook(book),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: CustomColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: CustomColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with continue reading label
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: CustomColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Continue Reading',
                    style: TextStyle(
                      color: CustomColors.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book cover
                  _buildBookCover(book, 120.w, 160.w),
                  SizedBox(width: 16.w),
                  // Book info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            color: CustomColors.textPrimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          book.author,
                          style: TextStyle(
                            color: CustomColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        _buildFileInfo(book),
                        SizedBox(height: 12.h),
                        // Progress indicator (placeholder for now)
                        _buildProgressIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(Book book, bool infoOnly) {
    return InkWell(
      onTap: () => readEbook(book),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: CustomColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: CustomColors.divider, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              _buildBookCover(book, 60.w, 80.w),
              SizedBox(width: 16.w),
              // Book info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  color: CustomColors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                book.author,
                                style: TextStyle(
                                  color: CustomColors.textSecondary,
                                  fontSize: 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _buildPopupMenu(book),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildFileInfo(book),
                    if (!infoOnly) ...[
                      SizedBox(height: 12.h),
                      _buildActionButtons(book),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(Book book, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: CustomColors.blackWithOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Default cover
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CustomColors.primaryWithOpacity(0.8),
                    CustomColors.primaryDark,
                  ],
                ),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: CustomColors.textOnPrimaryWithOpacity(0.5),
                size: width * 0.4,
              ),
            ),
            // Actual cover if available
            if (book.coverImageData.isNotEmpty)
              Image.memory(
                Uint8List.fromList(book.coverImageData),
                fit: BoxFit.cover,
                key: Key("cv_${book.id}"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo(Book book) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: CustomColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        "${book.fileType.toUpperCase()} • ${((book.fileSize / 1000000)).toStringAsFixed(1)}MB",
        style: TextStyle(
          color: CustomColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            color: CustomColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 4.h,
          decoration: BoxDecoration(
            color: CustomColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.3, // Placeholder - would be actual progress
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '30% complete', // Placeholder
          style: TextStyle(color: CustomColors.textSecondary, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Book book) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.list_rounded,
          onPressed: () {
            // TODO: Show table of contents
          },
        ),
        SizedBox(width: 12.w),
        _buildActionButton(
          icon: Icons.bookmark_outline_rounded,
          onPressed: () {
            // TODO: Show bookmarks
          },
        ),
        SizedBox(width: 12.w),
        _buildActionButton(
          icon: book.isFavorite == 1
              ? Icons.favorite_rounded
              : Icons.favorite_outline_rounded,
          color: book.isFavorite == 1 ? CustomColors.error : null,
          onPressed: () {
            DatabaseService.updateFavorite(
              book.id,
            ).whenComplete(() => env.bookstore.getBooks());
            setState(() {
              // The book object is immutable, so we need to rebuild the widget
              // The state will be updated when the store refreshes
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: CustomColors.dynamicWithOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp, color: color ?? CustomColors.primary),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPopupMenu(Book book) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20.sp,
        color: CustomColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (String result) {
        if (result == "Delete") {
          _showDeleteConfirmation(book);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: "Delete",
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18.sp,
                color: CustomColors.error,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delete',
                style: TextStyle(color: CustomColors.error, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Delete Book',
            style: TextStyle(
              color: CustomColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
            style: TextStyle(
              color: CustomColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: CustomColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                DatabaseService.deleteBook(
                  book.id,
                ).whenComplete(() => env.bookstore.getBooks());
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.error,
                foregroundColor: CustomColors.textOnPrimary,
              ),
              child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }
}
