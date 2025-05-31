// lib/views/widgets/news_card_widget.dart
import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

class NewsCardWidget extends StatelessWidget {
  final Article article;
  final bool isBookmarked; // Untuk artikel dari API (online)
  final VoidCallback
  onBookmarkTap; // Fungsi tap untuk bookmark atau aksi lain (mis. hapus)

  const NewsCardWidget({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkTap,
  });

  Widget _buildErrorImage(ThemeData theme) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: theme.cardColor, // Atau theme.highlightColor
        borderRadius: BorderRadius.circular(
          8.0,
        ), // Sesuaikan dengan ClipRRect di luar
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.hintColor.withOpacity(0.5),
        size: 40,
      ),
    );
  }

  Widget _buildLoadingImage(
    ThemeData theme,
    ColorScheme colorScheme,
    ImageChunkEvent loadingProgress,
  ) {
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: theme.cardColor, // Atau theme.highlightColor
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    String formattedDate = article.publishedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(
            article.publishedAt!,
          ) // Format lebih bersahabat
        : 'No date available';

    String sourceDisplay = article.sourceName?.isNotEmpty ?? false
        ? article.sourceName!
        : (article.author?.isNotEmpty ?? false
              ? article.author!
              : "Unknown Source");

    bool isLocalArticle =
        article.url == null || article.url!.isEmpty; // Indikasi artikel lokal

    Widget imageWidget;
    if (article.urlToImage != null && article.urlToImage!.isNotEmpty) {
      if (article.urlToImage!.startsWith('http')) {
        // Gambar dari Network
        imageWidget = Image.network(
          article.urlToImage!,
          width: 100.0,
          height: 100.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorImage(theme),
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return _buildLoadingImage(theme, colorScheme, loadingProgress);
              },
        );
      } else {
        // Asumsikan path file lokal
        File imageFile = File(article.urlToImage!);
        if (imageFile.existsSync()) {
          imageWidget = Image.file(
            imageFile,
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                "Error loading local image file: ${imageFile.path}, Error: $error",
              );
              return _buildErrorImage(theme);
            },
          );
        } else {
          debugPrint("Local image file does not exist: ${imageFile.path}");
          imageWidget = _buildErrorImage(theme);
        }
      }
    } else {
      imageWidget = _buildErrorImage(theme);
    }

    return InkWell(
      onTap: () {
        // Artikel lokal mungkin tidak memiliki URL web, jadi detailnya harus ditangani secara berbeda
        // Untuk saat ini, kita tetap mencoba membukanya di NewsDetailScreen,
        // yang mungkin perlu penyesuaian untuk menangani artikel lokal dengan baik.
        context.pushNamed(RouteName.articleDetail, extra: article);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              // Pastikan gambar dipotong sesuai border radius
              borderRadius: BorderRadius.circular(8.0),
              child: imageWidget,
            ),
            helper.hsMedium,
            Expanded(
              child: SizedBox(
                // Batasi tinggi kolom teks agar konsisten dengan tinggi gambar
                height: 100.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Atur space
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight
                                .bold, // Gunakan fontWeight dari helper jika ada
                            color: textTheme.bodyLarge?.color,
                            height: 1.2,
                          ), // Atur line height jika perlu
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        helper.vsSuperTiny,
                        Text(
                          sourceDisplay,
                          style: textTheme.bodySmall?.copyWith(
                            color: textTheme.bodyMedium?.color?.withOpacity(
                              0.7,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // helper.vsTiny, // Beri sedikit ruang sebelum tanggal
                    Text(
                      formattedDate,
                      style: textTheme.labelSmall?.copyWith(
                        color: theme.hintColor.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            helper.hsTiny,
            // Ikon aksi: Bookmark untuk artikel online, Hapus untuk artikel lokal
            InkWell(
              onTap:
                  onBookmarkTap, // Fungsi ini akan berbeda tergantung konteks
              borderRadius: BorderRadius.circular(
                20,
              ), // Area tap yang lebih baik
              child: Padding(
                padding: const EdgeInsets.all(6.0), // Padding untuk ikon
                child: Icon(
                  isLocalArticle
                      ? Icons.delete_outline_rounded
                      : (isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded),
                  color: isLocalArticle
                      ? theme.colorScheme.error.withOpacity(0.8)
                      : (isBookmarked ? colorScheme.primary : theme.hintColor),
                  size: 24.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
