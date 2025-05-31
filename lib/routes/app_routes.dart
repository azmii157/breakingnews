import 'package:breaknews/views/widgets/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'route_name.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteName.login:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Login Screen Placeholder'),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
