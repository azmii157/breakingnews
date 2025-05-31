// lib/views/widgets/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// Kelas untuk menyimpan data setiap halaman onboarding
class OnboardingPageUIData {
  final String backgroundImagePath; // Gambar latar belakang utama
  final String?
  foregroundImagePath; // Gambar ilustrasi/orang di depan (opsional)
  final String title;
  final String description;
  final Color
  dominantColor; // Warna dominan untuk halaman ini (misalnya untuk teks atau aksen)
  final Color
  backgroundColor; // Warna latar belakang jika gambar tidak full, atau untuk overlay

  OnboardingPageUIData({
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
    required this.dominantColor,
    required this.backgroundColor,
  });
}

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  // Daftar konten halaman onboarding
  // PENTING: Ganti imagePath dengan path aset gambar Anda yang valid
  final List<OnboardingPageUIData> _pages = [
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/oren.jpg',
      foregroundImagePath: 'assets/images/img intro 1.png',
      title: 'Hi-Tech', // Sesuai gambar
      description:
          'Explore the latest advancements and technological breakthroughs shaping our future.',
      dominantColor: Colors.orange.shade700,
      backgroundColor: Colors.orange.shade100,
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/biru.jpg',
      foregroundImagePath: 'assets/images/img intro 2.png',
      title: 'Personality', // Sesuai gambar
      description:
          'Understand diverse personalities and enhance your interpersonal skills effectively.',
      dominantColor: Colors.blue.shade700,
      backgroundColor: Colors.blue.shade100,
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/hejo.jpg',
      foregroundImagePath: 'assets/images/img intro 3.png',
      title: 'Global Mind', // Sesuai gambar
      description:
          'Develop a global mindset to navigate and succeed in an interconnected world.',
      dominantColor: Colors.green.shade700,
      backgroundColor: Colors.green.shade100,
    ),
    // Halaman ke-4 di gambar Anda adalah halaman selamat datang, mungkin bukan bagian dari PageView ini.
    // Jika ingin dimasukkan, tambahkan di sini.
  ];

  List<OnboardingPageUIData> get pages => _pages;
  int get totalPages => _pages.length;
  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPageOrFinish(BuildContext context) {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Halaman terakhir, arahkan ke halaman berikutnya (mis. Login atau halaman selamat datang SMK)
      // Berdasarkan gambar, halaman terakhir adalah halaman "Selamat Datang di SMK..."
      // Anda mungkin ingin navigasi khusus ke sana jika itu bukan bagian dari onboarding PageView.
      // Untuk contoh ini, kita akan ke halaman login.
      context.goNamed(
        RouteName.login,
      ); // Atau ke halaman selamat datang SMK jika ada rutenya
    }
  }

  // Tombol Skip mungkin tidak ada di desain baru ini, tapi bisa ditambahkan jika perlu
  // void skip(BuildContext context) {
  //   context.goNamed(RouteName.login);
  // }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context); // Tema aplikasi global

    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Consumer<OnboardingController>(
        // Consumer untuk mendapatkan controller
        builder: (context, controller, child) {
          // Dapatkan warna dominan dari halaman saat ini untuk tema tombol/indikator
          final currentPageData = controller.pages[controller.currentPage];
          final Color currentDominantColor = currentPageData.dominantColor;

          return Scaffold(
            // backgroundColor diatur per halaman di _OnboardingPageContentWidget
            body: Column(
              // Menggunakan Column untuk menumpuk PageView dan kontrol
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.totalPages,
                    itemBuilder: (context, index) {
                      final pageData = controller.pages[index];
                      return _OnboardingPageContentWidget(
                        key: ValueKey(
                          'onboarding_page_$index',
                        ), // Key untuk performa
                        backgroundImagePath: pageData.backgroundImagePath,
                        foregroundImagePath: pageData.foregroundImagePath,
                        title: pageData.title,
                        description: pageData.description,
                        dominantColor: pageData.dominantColor,
                        backgroundColor: pageData.backgroundColor,
                      );
                    },
                  ),
                ),
                // Kontrol di bagian bawah (Indikator dan Tombol)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: MediaQuery.of(context).padding.bottom > 0
                        ? 24.0
                        : 32.0, // Lebih banyak padding jika tidak ada safe area bawah
                  ),
                  // Warna latar bisa disesuaikan atau transparan
                  // color: appTheme.colorScheme.background, // atau controller.pages[controller.currentPage].backgroundColor
                  child: Column(
                    children: [
                      _buildPageIndicator(
                        controller,
                        currentDominantColor,
                        appTheme,
                      ),
                      SizedBox(
                        height: controller.totalPages > 1 ? 30.0 : 0,
                      ), // Beri jarak jika ada indikator
                      _buildNavigationButton(
                        context,
                        controller,
                        currentDominantColor,
                        appTheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(
    OnboardingController controller,
    Color activeColor,
    ThemeData theme,
  ) {
    if (controller.totalPages <= 1)
      return const SizedBox.shrink(); // Jangan tampilkan jika hanya 1 halaman

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: controller.currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: controller.currentPage == index
                ? activeColor
                : theme.colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    OnboardingController controller,
    Color buttonColor,
    ThemeData theme,
  ) {
    final bool isLastPage = controller.currentPage == controller.totalPages - 1;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => controller.nextPageOrFinish(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // Warna dominan halaman saat ini
          foregroundColor: Colors.white, // Asumsi teks putih kontras
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25.0,
            ), // Tombol lebih bulat seperti contoh
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(isLastPage ? 'Mulai' : 'Selanjutnya'), // Sesuai contoh
      ),
    );
  }
}

// Widget terpisah untuk konten setiap halaman onboarding
class _OnboardingPageContentWidget extends StatelessWidget {
  final String backgroundImagePath;
  final String? foregroundImagePath;
  final String title;
  final String description;
  final Color dominantColor;
  final Color backgroundColor;

  const _OnboardingPageContentWidget({
    super.key,
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
    required this.dominantColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: backgroundColor, // Warna latar belakang per halaman
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gambar Latar Belakang
          Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover, // Agar mengisi seluruh area
            errorBuilder: (context, error, stackTrace) => Container(
              color: backgroundColor, // Warna fallback jika gambar gagal dimuat
              child: Center(
                child: Icon(
                  Icons.error_outline,
                  color: dominantColor,
                  size: 50,
                ),
              ),
            ),
          ),

          // Overlay Gradasi (Opsional, untuk meningkatkan keterbacaan teks)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  backgroundColor.withOpacity(0.5),
                  backgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [
                  0.0,
                  0.3,
                  0.7,
                  1.0,
                ], // Sesuaikan stops untuk efek gradasi
              ),
            ),
          ),

          // Gambar Depan (Orang/Ilustrasi)
          if (foregroundImagePath != null)
            Positioned.fill(
              bottom:
                  screenHeight *
                  0.25, // Sesuaikan posisi agar tidak tertutup teks
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  foregroundImagePath!,
                  height: screenHeight * 0.5, // Sesuaikan ukuran gambar depan
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(), // Sembunyikan jika error
                ),
              ),
            ),

          // Konten Teks
          Positioned(
            bottom:
                screenHeight *
                0.05, // Posisi teks dari bawah (di atas tombol & indikator)
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Teks rata kiri seperti di contoh
              children: [
                Text(
                  title,
                  style: helper.headline2.copyWith(
                    // Gaya dari helper, lebih besar
                    color: Colors.white, // Teks putih agar kontras dengan latar
                    fontWeight: helper.bold,
                    shadows: [
                      // Bayangan teks untuk keterbacaan
                      const Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                helper.vsSmall,
                Text(
                  description,
                  style: helper.subtitle1.copyWith(
                    // Gaya dari helper
                    color: Colors.white.withOpacity(
                      0.9,
                    ), // Teks putih sedikit transparan
                    height: 1.5,
                    shadows: [
                      const Shadow(
                        blurRadius: 6.0,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
