import 'package:breaknews/views/widgets/bookmark_screen.dart';
import 'package:breaknews/views/widgets/edit_profile_screen.dart';
import 'package:breaknews/views/widgets/forgot_password_screen.dart';
import 'package:breaknews/views/widgets/reset_password_screen.dart';
import 'package:breaknews/views/widgets/home_screen.dart';
import 'package:breaknews/views/widgets/news_detail_screen.dart';
import 'package:breaknews/views/widgets/profile_screen.dart';
import 'package:breaknews/views/widgets/register_screen.dart';
import 'package:breaknews/views/widgets/splas_screen.dart';
import 'package:breaknews/views/widgets/settings_screen.dart';
import 'package:breaknews/views/widgets/widgets/change_password_screen.dart';
import 'package:breaknews/views/widgets/add_local_article_screen.dart'; // Import new screen
import 'package:breaknews/views/widgets/local_articles_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'views/widgets/onboarding_screen.dart';
import 'views/widgets/login_screen.dart';
import 'routes/route_name.dart';
import 'views/utils/helper.dart' as helper;
import 'data/models/article_model.dart';
import 'controllers/theme_controller.dart';
import 'views/widgets/main_scaffold.dart'; // Import the new MainScaffold
import 'package:breaknews/controllers/local_article_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      // MultiProvider membungkus MyApp
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(
          create: (_) => LocalArticleController(),
        ), // Controller disediakan di sini
        // Provider lain jika ada
      ],
      child: const MyApp(),
    ),
  );
}

// final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(); // Optional: For root navigator
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(); // Optional: For shell navigator

final GoRouter _router = GoRouter(
  initialLocation: RouteName.splash, // '/splash'
  // navigatorKey: _rootNavigatorKey, // Optional
  routes: <RouteBase>[
    GoRoute(
      path: RouteName.splash, // This is '/splash'
      name: RouteName.splash, // Name is also '/splash' as per current RouteName
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/introduction',
      name: RouteName.introduction, // 'introduction'
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: RouteName.login, // 'login'
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      name: RouteName.register, // 'register'
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterScreen();
      },
    ),

    // ShellRoute for main app navigation with BottomNavigationBar
    ShellRoute(
      // navigatorKey: _shellNavigatorKey, // Optional
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home', // Path for the home screen
          name: RouteName.home, // 'home'
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/bookmark', // Path for the bookmark screen
          name: RouteName.bookmark, // 'bookmark'
          builder: (BuildContext context, GoRouterState state) {
            return const BookmarkScreen();
          },
        ),
        GoRoute(
          // Screen for the "Add" action
          path: '/add-local-article',
          name: RouteName.addLocalArticle,
          builder: (BuildContext context, GoRouterState state) {
            return const AddLocalArticleScreen();
          },
        ),
        GoRoute(
          path: '/local-articles',
          name: RouteName.localArticles,
          builder: (BuildContext context, GoRouterState state) {
            return const LocalArticlesScreen();
          },
        ),
        GoRoute(
          path: '/profile', // Path for the profile screen
          name: RouteName.profile, // 'profile'
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
          // Nested routes for profile. These will be displayed within the MainScaffold
          // and the 'Profile' tab in BottomNavBar will remain active.
          routes: <RouteBase>[
            GoRoute(
              path: 'edit', // Relative path: /profile/edit
              name: RouteName.editProfile, // 'editProfile'
              builder: (BuildContext context, GoRouterState state) {
                final int? userId = state.extra as int?;
                if (userId != null) {
                  return EditProfileScreen(userId: userId);
                } else {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Error')),
                    body: const Center(
                      child: Text('User ID tidak valid untuk edit profil.'),
                    ),
                  );
                }
              },
            ),
            GoRoute(
              path: 'settings', // Relative path: /profile/settings
              name: RouteName.settings, // 'settings'
              builder: (BuildContext context, GoRouterState state) {
                return const SettingsScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path:
                      'change-password', // Relative: /profile/settings/change-password
                  name: RouteName.changePassword, // 'changePassword'
                  builder: (BuildContext context, GoRouterState state) {
                    return const ChangePasswordScreen();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Other top-level routes (not part of the BottomNav shell)
    GoRoute(
      path: '/article-detail',
      name: RouteName.articleDetail, // 'articleDetail'
      builder: (BuildContext context, GoRouterState state) {
        final Article? article = state.extra as Article?;
        if (article != null) {
          return NewsDetailScreen(article: article);
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Artikel tidak ditemukan.')),
          );
        }
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteName.forgotPassword, // 'forgotPassword'
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordScreen();
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: RouteName.resetPassword, // 'resetPassword'
      builder: (BuildContext context, GoRouterState state) {
        final String? email = state.extra as String?;
        if (email != null) {
          return ResetPasswordScreen(email: email);
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Error")),
          body: const Center(
            child: Text("Email tidak valid untuk reset password."),
          ),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Halaman tidak ditemukan: ${state.error?.message ?? state.uri.toString()}',
      ),
    ),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return MaterialApp.router(
      title: 'Aplikasi Berita Anda',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: helper.cPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: helper.cPrimary,
          brightness: Brightness.light,
          primary: helper.cPrimary,
          secondary: helper.cTextBlue,
        ),
        scaffoldBackgroundColor: helper.cWhite,
        appBarTheme: AppBarTheme(
          backgroundColor: helper.cPrimary,
          foregroundColor: helper.cWhite,
          elevation: 1.0,
          titleTextStyle: helper.headline4.copyWith(
            color: helper.cWhite,
            fontSize: 18,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: helper.headline1.copyWith(color: helper.cBlack),
          displayMedium: helper.headline2.copyWith(color: helper.cBlack),
          displaySmall: helper.headline3.copyWith(color: helper.cBlack),
          headlineMedium: helper.headline4.copyWith(color: helper.cBlack),
          titleLarge: helper.subtitle1.copyWith(
            color: helper.cBlack,
            fontWeight: helper.bold,
          ),
          bodyLarge: helper.subtitle1.copyWith(color: helper.cTextBlue),
          bodyMedium: helper.subtitle2.copyWith(color: helper.cTextBlue),
          labelLarge: helper.subtitle1.copyWith(
            color: helper.cWhite,
            fontWeight: helper.semibold,
          ),
          bodySmall: helper.caption.copyWith(color: helper.cTextBlue),
          labelSmall: helper.overline.copyWith(color: helper.cTextBlue),
        ).apply(fontFamily: helper.headline1.fontFamily),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: helper.cPrimary,
            foregroundColor: helper.cWhite,
            textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: helper.cPrimary,
            side: BorderSide(color: helper.cPrimary, width: 1.5),
            textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: helper.enableBorder,
          enabledBorder: helper.enableBorder,
          focusedBorder: helper.focusedBorder,
          errorBorder: helper.errorBorder,
          focusedErrorBorder: helper.focusedErrorBorder,
          labelStyle: helper.subtitle2.copyWith(color: helper.cTextBlue),
          hintStyle: helper.subtitle2.copyWith(color: helper.cLinear),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: helper.cWhite,
          selectedItemColor: helper.cPrimary,
          unselectedItemColor: helper.cLinear.withOpacity(0.8),
          // Add text style for labels if needed
          // selectedLabelStyle: helper.caption.copyWith(fontWeight: helper.medium),
          // unselectedLabelStyle: helper.caption,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: helper.cPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: helper.cPrimary,
          brightness: Brightness.dark,
          primary: helper.cPrimary,
          secondary: helper.cLinear,
          background: const Color(0xFF121212),
          surface: const Color(
            0xFF1E1E1E,
          ), // Used by Card, BottomNavBar by default
          error: helper.cError,
          onPrimary: helper.cWhite,
          onSecondary: helper.cBlack,
          onBackground: helper.cWhite.withOpacity(0.87),
          onSurface: helper.cWhite.withOpacity(0.87), // Text on Cards/Surface
          onError: helper.cWhite,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: helper.cWhite,
          elevation: 1.0,
          titleTextStyle: helper.headline4.copyWith(
            color: helper.cWhite,
            fontSize: 18,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: helper.headline1.copyWith(
            color: helper.cWhite.withOpacity(0.87),
          ),
          displayMedium: helper.headline2.copyWith(
            color: helper.cWhite.withOpacity(0.87),
          ),
          displaySmall: helper.headline3.copyWith(
            color: helper.cWhite.withOpacity(0.87),
          ),
          headlineMedium: helper.headline4.copyWith(
            color: helper.cWhite.withOpacity(0.87),
          ),
          titleLarge: helper.subtitle1.copyWith(
            color: helper.cWhite.withOpacity(0.87),
            fontWeight: helper.bold,
          ),
          bodyLarge: helper.subtitle1.copyWith(
            color: helper.cWhite.withOpacity(0.87),
          ),
          bodyMedium: helper.subtitle2.copyWith(
            color: helper.cWhite.withOpacity(0.70),
          ),
          labelLarge: helper.subtitle1.copyWith(
            color: helper.cWhite,
            fontWeight: helper.semibold,
          ),
          bodySmall: helper.caption.copyWith(
            color: helper.cWhite.withOpacity(0.70),
          ),
          labelSmall: helper.overline.copyWith(
            color: helper.cWhite.withOpacity(0.70),
          ),
        ).apply(fontFamily: helper.headline1.fontFamily),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: helper.cPrimary,
            foregroundColor: helper.cWhite,
            textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: helper.cPrimary,
            side: BorderSide(color: helper.cPrimary, width: 1.5),
            textStyle: helper.subtitle1.copyWith(fontWeight: helper.semibold),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: helper.enableBorder.copyWith(
            borderSide: BorderSide(color: helper.cGrey.withOpacity(0.5)),
          ),
          enabledBorder: helper.enableBorder.copyWith(
            borderSide: BorderSide(color: helper.cGrey.withOpacity(0.5)),
          ),
          focusedBorder: helper.focusedBorder.copyWith(
            borderSide: BorderSide(color: helper.cPrimary),
          ),
          errorBorder: helper.errorBorder.copyWith(
            borderSide: BorderSide(color: helper.cError),
          ),
          focusedErrorBorder: helper.focusedErrorBorder.copyWith(
            borderSide: BorderSide(color: helper.cError),
          ),
          labelStyle: helper.subtitle2.copyWith(color: helper.cGrey),
          hintStyle: helper.subtitle2.copyWith(
            color: helper.cLinear.withOpacity(0.6),
          ),
          prefixIconColor: helper.cLinear.withOpacity(0.8),
          fillColor: Colors.grey.shade800,
          filled: true,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E), // Matches dark AppBar
          selectedItemColor: helper.cPrimary,
          unselectedItemColor: helper.cGrey.withOpacity(0.7),
          // selectedLabelStyle: helper.caption.copyWith(fontWeight: helper.medium),
          // unselectedLabelStyle: helper.caption,
        ),
      ),
      themeMode: themeController.themeMode,
    );
  }
}
