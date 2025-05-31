// lib/views/widgets/news_detail_screen.dart
import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/article_model.dart';
import '../utils/helper.dart' as helper;

class NewsDetailScreen extends StatelessWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  Future<void> _launchURL(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak tersedia untuk artikel ini.')),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
        );
      }
    }
  }

  // Helper widget untuk placeholder saat loading gambar
  Widget _buildLoadingPlaceholder(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double imageHeight,
  ) {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: theme.highlightColor.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  // Helper widget untuk placeholder jika gambar error atau tidak ada
  Widget _buildImageErrorPlaceholder(
    BuildContext context,
    ThemeData theme,
    double imageHeight, {
    String? message,
  }) {
    return Container(
      width: double.infinity,
      height: imageHeight,
      color: theme.cardColor.withOpacity(
        0.8,
      ), // Sedikit transparan agar tidak terlalu solid
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: theme.hintColor.withOpacity(0.7),
            size: 60,
          ),
          if (message != null) ...[
            helper.vsSmall,
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight * 0.35; // Tinggi gambar konsisten

    String formattedDate = article.publishedAt != null
        ? DateFormat(
            'EEEE, dd MMMM yyyy, HH:mm', // Format 'yyyy' ditambahkan untuk kejelasan tahun
            'id_ID',
          ).format(article.publishedAt!)
        : 'Tanggal tidak tersedia';

    String authorDisplay = article.author?.isNotEmpty ?? false
        ? article.author!
        : (article.sourceName?.isNotEmpty ?? false
              ? article.sourceName!
              : 'Sumber tidak diketahui');

    Widget imageDisplayWidget;
    if (article.urlToImage != null && article.urlToImage!.isNotEmpty) {
      if (article.urlToImage!.startsWith('http')) {
        // Gambar dari Network
        imageDisplayWidget = Image.network(
          article.urlToImage!,
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingPlaceholder(
              context,
              theme,
              colorScheme,
              imageHeight,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
              "Error loading network image in Detail: ${article.urlToImage}, Error: $error",
            );
            return _buildImageErrorPlaceholder(
              context,
              theme,
              imageHeight,
              message: "Gagal memuat gambar",
            );
          },
        );
      } else {
        // Asumsikan path file lokal
        File imageFile = File(article.urlToImage!);
        if (imageFile.existsSync()) {
          imageDisplayWidget = Image.file(
            imageFile,
            width: double.infinity,
            height: imageHeight,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                "Error loading local file image in Detail: ${article.urlToImage}, Error: $error",
              );
              return _buildImageErrorPlaceholder(
                context,
                theme,
                imageHeight,
                message: "Gambar lokal tidak ditemukan",
              );
            },
          );
        } else {
          debugPrint(
            "Local image file does not exist in Detail: ${article.urlToImage}",
          );
          imageDisplayWidget = _buildImageErrorPlaceholder(
            context,
            theme,
            imageHeight,
            message: "File gambar tidak ada",
          );
        }
      }
    } else {
      // Tidak ada path gambar
      imageDisplayWidget = _buildImageErrorPlaceholder(
        context,
        theme,
        imageHeight,
        message: "Gambar tidak tersedia",
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          article.sourceName ?? 'Detail Berita',
          style: theme.appBarTheme.titleTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              debugPrint('Tombol Share ditekan untuk: ${article.title}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Share belum diimplementasikan.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- CARD UNTUK GAMBAR DAN INFO UTAMA ---
            Card(
              margin: const EdgeInsets.fromLTRB(
                12.0,
                12.0,
                12.0,
                0,
              ), // Mengurangi margin bawah card
              elevation: 3.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              clipBehavior: Clip.antiAlias,
              color: theme.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tampilkan widget gambar yang sudah ditentukan
                  Hero(
                    // Tag Hero harus unik, kombinasi judul dan timestamp bisa lebih aman
                    tag:
                        article.urlToImage ??
                        (article.title +
                            (article.publishedAt?.toIso8601String() ?? "")),
                    child: imageDisplayWidget,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          article.title,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textTheme
                                .displayLarge
                                ?.color, // Sesuaikan dengan warna teks tema
                          ),
                        ),
                        helper.vsMedium,
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 16,
                              color: theme.hintColor,
                            ),
                            helper.hsTiny,
                            Expanded(
                              child: Text(
                                authorDisplay,
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        helper.vsSuperTiny,
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: theme.hintColor,
                            ),
                            helper.hsTiny,
                            Text(
                              formattedDate,
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- KONTEN ARTIKEL ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0, // Beri jarak dari card di atas
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.content != null && article.content!.isNotEmpty)
                    Text(
                      // Menghapus '[+... chars]' jika ada
                      article.content!.contains(' [+')
                          ? article.content!.substring(
                              0,
                              article.content!.indexOf(' [+'),
                            )
                          : article.content!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  else if (article.description != null &&
                      article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.justify,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          "Konten detail tidak tersedia untuk artikel ini.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ),
                  helper.vsLarge,
                  if (article.url != null && article.url!.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.open_in_browser_rounded,
                          size: 20,
                        ),
                        label: Text(
                          'Baca Selengkapnya di ${article.sourceName ?? "Sumber"}',
                        ),
                        onPressed: () {
                          _launchURL(context, article.url);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                  helper.vsLarge,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
