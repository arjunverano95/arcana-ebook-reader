import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:arcana_ebook_reader/dto/BookDtos.dart';
import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});
  @override
  Widget build(BuildContext context) {
    return const FavoritesBody();
  }
}

class FavoritesBody extends StatefulWidget {
  const FavoritesBody({super.key});
  @override
  FavoritesBodyState createState() => FavoritesBodyState();
}

class FavoritesBodyState extends State<FavoritesBody> {
  String _sort = "asc";
  bool _isGridView = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookDto> _getFilteredFavorites() {
    List<BookDto> books = List.from(env.bookstore.books);
    books = books.where((book) => book.isFavorite == 1).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      books = books.where((book) {
        return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    if (_sort == "asc") {
      books.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sort == "desc") {
      books.sort((a, b) => b.title.compareTo(a.title));
    } else if (_sort == "recent") {
      books.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    }

    return books;
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CustomColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: CustomColors.divider),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search favorites...',
          hintStyle: TextStyle(
            color: CustomColors.textTertiary,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: CustomColors.textSecondary,
            size: 20.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: CustomColors.textSecondary,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        style: TextStyle(color: CustomColors.textPrimary, fontSize: 14.sp),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildHeader() {
    final favoriteCount = _getFilteredFavorites().length;
    final totalFavorites = env.bookstore.books
        .where((book) => book.isFavorite == 1)
        .length;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColors.errorWithOpacity(0.1),
            CustomColors.errorWithOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CustomColors.errorWithOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: CustomColors.errorWithOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: CustomColors.error,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Favorites',
                  style: TextStyle(
                    color: CustomColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _searchQuery.isNotEmpty
                      ? '$favoriteCount of $totalFavorites favorites shown'
                      : '$totalFavorites favorite books',
                  style: TextStyle(
                    color: CustomColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              color: CustomColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Title A-Z', 'asc'),
                  SizedBox(width: 8.w),
                  _buildSortChip('Title Z-A', 'desc'),
                  SizedBox(width: 8.w),
                  _buildSortChip('Recently Added', 'recent'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sort == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? CustomColors.textOnPrimary
              : CustomColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: CustomColors.primary,
      backgroundColor: CustomColors.backgroundSecondary,
      side: BorderSide(
        color: isSelected ? CustomColors.primary : CustomColors.divider,
      ),
      onSelected: (selected) {
        setState(() {
          _sort = value;
        });
      },
      checkmarkColor: CustomColors.textOnPrimary,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    );
  }

  Widget _buildViewToggle() {
    final favoriteCount = _getFilteredFavorites().length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$favoriteCount favorite books',
            style: TextStyle(
              color: CustomColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: CustomColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  icon: Icons.view_list_rounded,
                  isSelected: !_isGridView,
                  onPressed: () => setState(() => _isGridView = false),
                ),
                _buildToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView,
                  onPressed: () => setState(() => _isGridView = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isSelected
              ? CustomColors.textOnPrimary
              : CustomColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListView(List<BookDto> books) {
    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        return AnimationConfiguration.staggeredList(
          position: i,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(child: BookTile(book: books[i])),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<BookDto> books) {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) {
        return AnimationConfiguration.staggeredGrid(
          position: i,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: ScaleAnimation(
            child: FadeInAnimation(child: _buildGridBookCard(books[i])),
          ),
        );
      },
    );
  }

  Widget _buildGridBookCard(BookDto book) {
    return InkWell(
      onTap: () => _openBook(book),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: CustomColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                child: _buildBookCover(book),
              ),
            ),
            // Book info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        color: CustomColors.textPrimary,
                        fontSize: 14.sp,
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
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: CustomColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            book.fileType.toUpperCase(),
                            style: TextStyle(
                              color: CustomColors.textSecondary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.favorite_rounded,
                          size: 16.sp,
                          color: CustomColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover(BookDto book) {
    return Container(
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
                size: 32.sp,
              ),
            ),
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

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: CustomColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CustomColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.favorite_outline_rounded,
            size: 64.sp,
            color: CustomColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'No favorites found'
                : 'No favorite books yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: CustomColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Mark books as favorites by tapping the heart icon',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => env.navigation.navigate('library'),
              icon: Icon(Icons.library_books_rounded, size: 18.sp),
              label: Text('Browse Library'),
            ),
          ],
        ],
      ),
    );
  }

  void _openBook(BookDto book) {
    // TODO: Implement book opening
  }

  @override
  Widget build(BuildContext context) {
    final filteredFavorites = _getFilteredFavorites();

    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColors.background,
          foregroundColor: CustomColors.textPrimary,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 24.sp,
              color: CustomColors.textPrimary,
            ),
            onPressed: () => env.navigation.pop(),
          ),
          title: Text(
            'Favorites',
            style: TextStyle(
              color: CustomColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildSortOptions(),
            SizedBox(height: 16.h),
            _buildViewToggle(),
            Observer(
              builder: (_) {
                if (filteredFavorites.isEmpty) {
                  return Container(child: _buildEmptyState());
                }

                return Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: _isGridView
                        ? _buildGridView(filteredFavorites)
                        : _buildListView(filteredFavorites),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
