// lib/views/widgets/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:breaknews/views/widgets/sort_by_options_widget.dart';
import '../../controllers/home_controller.dart';
import '../../data/models/article_model.dart';
import 'news_card_widget.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// --- WIDGET KARTU BERITA UNGGULAN (FEATURED/HEADLINE CAROUSEL) ---
class _FeaturedNewsCardWidget extends StatelessWidget {
  final Article article;
  const _FeaturedNewsCardWidget({required this.article});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.8;
    const cardHeight = 200.0;

    return InkWell(
      onTap: () {
        context.pushNamed(RouteName.articleDetail, extra: article);
        debugPrint('Featured Card tapped: ${article.title}');
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.only(
          left: 16.0,
          top: 8.0,
          bottom: 12.0,
          right: 8.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 5.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                Image.network(
                  article.urlToImage!,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: theme.highlightColor.withOpacity(0.2),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.highlightColor,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: theme.hintColor,
                        size: 50,
                      ),
                    );
                  },
                )
              else
                Container(
                  color: theme.highlightColor,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.hintColor,
                    size: 50,
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: cardHeight * 0.55, // Perbesar area gradient
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.85), // Lebih pekat
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12.0,
                left: 12.0,
                right: 12.0,
                child: Text(
                  article.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white, // Teks putih di atas scrim gelap
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET UTAMA LAYAR HOME ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // If HomeController needs to be initialized once when HomeScreen first appears,
    // consider doing it here or in a way that survives widget rebuilds if not using Provider above this widget.
    // Provider.of<HomeController>(context, listen: false).fetchTopHeadlinesByCategory("Headline");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    // HomeScreen now provides its own HomeController
    return ChangeNotifierProvider(
      create: (context) => HomeController(),
      child: SafeArea(
        // Ensures content is not obscured by system UI like status bar
        child: GestureDetector(
          onTap: () {
            if (_searchFocusNode.hasFocus) {
              _searchFocusNode.unfocus();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, theme),
              Consumer<HomeController>(
                builder: (context, controller, child) {
                  return _buildSearchBarAndFilter(context, theme, controller);
                },
              ),
              Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.isSearchActive && controller.isLoading) {
                    return const SizedBox.shrink();
                  }
                  if (controller.isSearchActive &&
                      !controller.isLoading &&
                      controller.articles.isNotEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _buildCategoryTabs(context, controller, theme);
                },
              ),
              Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.isSearchActive) return const SizedBox.shrink();
                  if (controller.isLoading && controller.articles.isEmpty) {
                    return SizedBox(
                      height: 200.0, // Height of the featured news carousel
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  if (controller.articles.isEmpty ||
                      (controller.errorMessage != null &&
                          controller.articles.isEmpty)) {
                    return const SizedBox.shrink();
                  }
                  final List<Article> featuredArticles = controller.articles
                      .take(5)
                      .toList();
                  if (featuredArticles.isEmpty) return const SizedBox.shrink();
                  return _buildFeaturedNewsCarousel(
                    context,
                    featuredArticles,
                    controller,
                  );
                },
              ),
              Consumer<HomeController>(
                builder: (context, controller, child) {
                  if (controller.isSearchActive &&
                      controller.currentSearchQuery != null &&
                      controller.currentSearchQuery!.isNotEmpty) {
                    if (controller.isLoading) return const SizedBox.shrink();
                    return _buildSectionTitle(
                      'Hasil untuk: "${controller.currentSearchQuery}"',
                      theme,
                    );
                  } else if (!controller.isSearchActive &&
                      controller.selectedCategory.isNotEmpty &&
                      controller.selectedCategory.toLowerCase() != "headline" &&
                      controller.selectedCategory.toLowerCase() !=
                          "top stories" &&
                      controller.selectedCategory.toLowerCase() != "all news") {
                    return _buildSectionTitle(
                      'Kategori: ${controller.selectedCategory}',
                      theme,
                    );
                  }
                  return _buildSectionTitle("Berita Utama Terkini", theme);
                },
              ),
              Expanded(
                child: Consumer<HomeController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading && controller.articles.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    if (controller.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Gagal memuat berita:\n${controller.errorMessage}',
                            style: textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (controller.articles.isEmpty && !controller.isLoading) {
                      String message =
                          controller.isSearchActive &&
                              controller.currentSearchQuery != null
                          ? 'Tidak ada hasil untuk "${controller.currentSearchQuery}".'
                          : 'Tidak ada berita untuk kategori "${controller.selectedCategory}".';
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            message,
                            style: textTheme.titleMedium?.copyWith(
                              color: textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () =>
                          controller.isSearchActive &&
                              controller.currentSearchQuery != null
                          ? controller.searchArticles(
                              controller.currentSearchQuery!,
                            )
                          : controller.fetchTopHeadlinesByCategory(
                              controller.selectedCategory,
                            ),
                      color: theme.colorScheme.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: controller.articles.length,
                        itemBuilder: (context, index) {
                          final article = controller.articles[index];
                          bool isBookmarked = controller.isArticleBookmarked(
                            article.url,
                          );
                          return NewsCardWidget(
                            article: article,
                            isBookmarked: isBookmarked,
                            onBookmarkTap: () {
                              controller.toggleBookmark(article);
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBookmarked
                                        ? "'${article.title}' dihapus dari bookmark."
                                        : "'${article.title}' ditambahkan ke bookmark.",
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0, // Adjusted top padding for SafeArea
        bottom: 8.0,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icon.png',
            height: 50.0,
            width: 50.0,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.newspaper_rounded,
                color: theme.colorScheme.primary,
                size: 28.0,
              );
            },
          ),
          helper.hsLarge,
          Text(
            "Break News",
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBarAndFilter(
    BuildContext context,
    ThemeData theme,
    HomeController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ).copyWith(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: "Cari berita, artikel...",
                hintStyle: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.hintColor,
                  size: 22,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : helper.cGrey.withOpacity(0.7),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: theme.hintColor,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          controller.fetchTopHeadlinesByCategory(
                            controller.categories.firstWhere(
                              (cat) => cat.toLowerCase() == "headline",
                              orElse: () => controller.categories.first,
                            ),
                          );
                          _searchFocusNode.unfocus();
                          // Notify the controller about the change to ensure UI updates
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                // setState to rebuild and show/hide clear button
                setState(() {});
              },
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  controller.searchArticles(value.trim());
                } else {
                  controller.fetchTopHeadlinesByCategory(
                    controller.categories.firstWhere(
                      (cat) => cat.toLowerCase() == "headline",
                      orElse: () => controller.categories.first,
                    ),
                  );
                }
                _searchFocusNode.unfocus();
              },
            ),
          ),
          helper.hsMedium,
          InkWell(
            onTap: () {
              _showSortByFilterOptions(context, controller);
              debugPrint("Filter button tapped");
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : helper.cGrey.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: theme.textTheme.bodyMedium?.color,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(
    BuildContext context,
    HomeController controller,
    ThemeData theme,
  ) {
    return Container(
      height: 45.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final bool isSelected =
              category == controller.selectedCategory &&
              !controller.isSearchActive;

          return GestureDetector(
            onTap: () {
              _searchController.clear();
              _searchFocusNode.unfocus();
              controller.onCategorySelected(category);
              setState(() {}); // To update clear button if search was active
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              margin: EdgeInsets.only(
                right: index == controller.categories.length - 1 ? 0 : 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20.0),
                border: isSelected
                    ? null
                    : Border.all(color: theme.dividerColor),
              ),
              child: Text(
                category,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 12.0,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme
              .textTheme
              .bodyLarge
              ?.color, // Ensure text color matches theme
        ),
      ),
    );
  }

  Widget _buildFeaturedNewsCarousel(
    BuildContext context,
    List<Article> featuredArticles,
    HomeController controller, // Kept for potential future use with controller
  ) {
    if (featuredArticles.isEmpty) return const SizedBox.shrink();
    const double carouselHeight = 200.0;
    return SizedBox(
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredArticles.length,
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ), // Consistent padding
        itemBuilder: (context, index) {
          final article = featuredArticles[index];
          return _FeaturedNewsCardWidget(article: article);
        },
      ),
    );
  }

  void _showSortByFilterOptions(
    BuildContext context,
    HomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent, // Bottom sheet will define its own bg
      builder: (BuildContext bc) {
        // The SortByOptionsWidget will use the HomeController from this screen's provider
        return ChangeNotifierProvider.value(
          value: controller,
          child: const SortByOptionsWidget(),
        );
      },
    );
  }
}
