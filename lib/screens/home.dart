import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:arcana_ebook_reader/env.dart';
import 'package:arcana_ebook_reader/extension.dart';
import 'package:arcana_ebook_reader/models/Book.dart';
import 'package:arcana_ebook_reader/util/customColors.dart';
import 'package:arcana_ebook_reader/widgets/bookTile.dart';
import 'package:arcana_ebook_reader/widgets/importBooks.dart';
import 'package:arcana_ebook_reader/widgets/loading_overlay.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBody();
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody>
    with SingleTickerProviderStateMixin {
  HomeBodyState();
  late AnimationController _recentReadAnimationController;
  late Animation<double> _recentReadAnimation;

  @override
  void initState() {
    super.initState();
    _recentReadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _recentReadAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_recentReadAnimationController);
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28.sp,
              color: CustomColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Ready to continue reading?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              color: CustomColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalBooks = env.bookstore.books.length;
    final favoriteBooks = env.bookstore.books
        .where((book) => book.isFavorite == 1)
        .length;
    final recentBooks = env.bookstore.books
        .where((book) => book.lastRead != null)
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Books',
              totalBooks.toString(),
              Icons.library_books_outlined,
              CustomColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Favorites',
              favoriteBooks.toString(),
              Icons.favorite_outline,
              CustomColors.error,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Reading',
              recentBooks.toString(),
              Icons.menu_book_outlined,
              CustomColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CustomColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CustomColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: CustomColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: CustomColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRead() {
    Book? recentRead;
    if (env.bookstore.books.isNotEmpty) {
      List<Book> recentReads = List.from(
        env.bookstore.books.where((item) => item.lastRead != null),
      );

      if (recentReads.isNotEmpty) {
        recentReads.sort((a, b) => b.lastRead.compareToWithNull(a.lastRead));
        recentRead = recentReads[0];
      }
    }

    if (recentRead != null) {
      return Container(
        margin: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Reading',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => env.navigation.navigate('library'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: CustomColors.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            BookTile(book: recentRead, size: CoverSize.lg),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildRecentlyAdded() {
    List<Book> recentAdded = [];
    if (env.bookstore.books.isNotEmpty) {
      recentAdded = List.from(env.bookstore.books);
      recentAdded.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      recentAdded = recentAdded.take(5).toList();
    }

    if (recentAdded.isNotEmpty) {
      return Container(
        margin: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Added',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => env.navigation.navigate('library'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: CustomColors.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentAdded.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, i) {
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: BookTile(book: recentAdded[i], infoOnly: true),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
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
            Icons.library_books_outlined,
            size: 64.sp,
            color: CustomColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Your Library is Empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: CustomColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Import your first ebook to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: CustomColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              final overlay = LoadingOverlay.of(context);
              overlay.during(showImportDialog());
            },
            icon: Icon(Icons.add, size: 20.sp),
            label: Text('Import Books', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _recentReadAnimationController.forward();
    final overlay = LoadingOverlay.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.background,
        drawer: _buildModernDrawer(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColors.background,
          foregroundColor: CustomColors.textPrimary,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                size: 24.sp,
                color: CustomColors.textPrimary,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            'Arcana Ebook Reader',
            style: TextStyle(
              color: CustomColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                size: 24.sp,
                color: CustomColors.textPrimary,
              ),
              onPressed: () {
                // Option 1: Show search dialog and navigate to library with search query
                _showSearchDialog(context);

                // Option 2: Direct navigation to library (uncomment below)
                // env.navigation.navigate('library', arguments: '');
              },
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              Observer(builder: (_) => _buildQuickStats()),
              SizedBox(height: 24.h),
              Observer(
                builder: (_) => env.bookstore.books.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          FadeTransition(
                            opacity: _recentReadAnimation,
                            child: _buildRecentRead(),
                          ),
                          _buildRecentlyAdded(),
                        ],
                      ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => overlay.during(showImportDialog()),
          backgroundColor: CustomColors.primary,
          foregroundColor: CustomColors.textOnPrimary,
          icon: Icon(Icons.add, size: 20.sp),
          label: Text(
            'Import',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: CustomColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              color: CustomColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60.w,
                    width: 60.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/arcana_ebook_reader_transparent.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Arcana Ebook  Reader',
                    style: TextStyle(
                      color: CustomColors.textOnPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Personal Library',
                    style: TextStyle(
                      color: CustomColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: CustomColors.divider, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                    isSelected: true,
                  ),
                  _buildDrawerItem(
                    icon: Icons.library_books_rounded,
                    title: 'Library',
                    onTap: () {
                      Navigator.pop(context);
                      env.navigation.navigate('library');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'Favorites',
                    onTap: () {
                      Navigator.pop(context);
                      env.navigation.navigate('favorites');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.file_download_rounded,
                    title: 'Import Books',
                    onTap: () {
                      Navigator.pop(context);
                      final overlay = LoadingOverlay.of(context);
                      overlay.during(showImportDialog());
                    },
                  ),
                  Divider(color: CustomColors.divider, height: 32.h),
                  _buildDrawerItem(
                    icon: Icons.exit_to_app_rounded,
                    title: 'Exit',
                    onTap: () => SystemNavigator.pop(),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? CustomColors.error
              : isSelected
              ? CustomColors.primary
              : CustomColors.textSecondary,
          size: 22.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? CustomColors.error
                : isSelected
                ? CustomColors.primary
                : CustomColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        selected: isSelected,
        selectedTileColor: CustomColors.primaryWithOpacity(0.1),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.cardBackground,
          title: Text(
            'Search Books',
            style: TextStyle(
              color: CustomColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Enter book title or author',
              hintStyle: TextStyle(
                color: CustomColors.textTertiary,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: CustomColors.textSecondary,
                size: 20.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: CustomColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: CustomColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
            style: TextStyle(color: CustomColors.textPrimary, fontSize: 14.sp),
            autofocus: true,
            onSubmitted: (value) {
              Navigator.of(context).pop();
              if (value.isNotEmpty) {
                env.navigation.navigate('library', arguments: value);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: CustomColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (searchController.text.isNotEmpty) {
                  env.navigation.navigate(
                    'library',
                    arguments: searchController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.primary,
                foregroundColor: CustomColors.textOnPrimary,
              ),
              child: Text('Search', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }
}
