// lib/views/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:breaknews/routes/route_name.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  // Determines the selected index for the BottomAppBar items (0-3).
  // Returns -1 if the FAB's screen (AddLocalArticleScreen) is active.
  int _calculateBottomAppBarIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String? currentRouteName = state.topRoute?.name;
    final String location = state.uri.toString();

    if (currentRouteName == RouteName.home ||
        location.startsWith('/${RouteName.home}'))
      return 0;
    if (currentRouteName == RouteName.bookmark ||
        location.startsWith('/${RouteName.bookmark}'))
      return 1;
    // Index 2 in BottomAppBar is for Local Articles
    if (currentRouteName == RouteName.localArticles ||
        location.startsWith('/${RouteName.localArticles}'))
      return 2;
    // Index 3 in BottomAppBar is for Profile
    if (currentRouteName == RouteName.profile ||
        location.startsWith('/${RouteName.profile}'))
      return 3;

    // If AddLocalArticleScreen is active, no BottomAppBar item is "selected"
    if (currentRouteName == RouteName.addLocalArticle) return -1;

    return 0; // Default to home
  }

  void _onBottomAppBarItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: // Home
        context.goNamed(RouteName.home);
        break;
      case 1: // Bookmark
        context.goNamed(RouteName.bookmark);
        break;
      case 2: // Local Articles
        context.goNamed(RouteName.localArticles);
        break;
      case 3: // Profile
        context.goNamed(RouteName.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int bottomAppBarIndex = _calculateBottomAppBarIndex(context);
    final ThemeData theme = Theme.of(context);
    final bool isAddArticleScreenActive =
        GoRouterState.of(context).topRoute?.name == RouteName.addLocalArticle;

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (GoRouterState.of(context).topRoute?.name !=
              RouteName.addLocalArticle) {
            context.goNamed(RouteName.addLocalArticle);
          }
        },
        backgroundColor: isAddArticleScreenActive
            ? theme
                  .colorScheme
                  .secondaryContainer // A distinct color when active
            : theme.colorScheme.primaryContainer, // Default FAB color
        foregroundColor: isAddArticleScreenActive
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onPrimaryContainer,
        elevation: isAddArticleScreenActive ? 4.0 : 2.0,
        shape: const CircleBorder(), // Ensures it's circular
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // Space for the FAB
        // color: theme.bottomAppBarTheme.color, // Inherited from theme
        // elevation: theme.bottomAppBarTheme.elevation, // Inherited
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_filled,
              label: 'Home',
              isSelected: bottomAppBarIndex == 0,
              onTap: () => _onBottomAppBarItemTapped(0, context),
            ),
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.bookmark_border_outlined,
              selectedIcon: Icons.bookmark_rounded,
              label: 'Bookmark',
              isSelected: bottomAppBarIndex == 1,
              onTap: () => _onBottomAppBarItemTapped(1, context),
            ),
            const SizedBox(width: 48), // Space for the FAB notch
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.article_outlined, // Icon for Local Articles
              selectedIcon: Icons.article, // Filled version
              label: 'Local',
              isSelected: bottomAppBarIndex == 2,
              onTap: () => _onBottomAppBarItemTapped(2, context),
            ),
            _buildBottomAppBarItem(
              context: context,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              isSelected: bottomAppBarIndex == 3,
              onTap: () => _onBottomAppBarItemTapped(3, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAppBarItem({
    required BuildContext context,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color itemColor = isSelected
        ? theme.bottomNavigationBarTheme.selectedItemColor ??
              theme.colorScheme.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.hintColor;

    final double iconSize = 24.0;
    final double labelFontSize = 10.0;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6.0,
          ), // Adjusted padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isSelected ? (selectedIcon ?? icon) : icon,
                color: itemColor,
                size: iconSize,
              ),
              const SizedBox(height: 3), // Fine-tune spacing
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: labelFontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
