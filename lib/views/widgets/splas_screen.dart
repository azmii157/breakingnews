import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:breaknews/routes/route_name.dart';
import '../utils/helper.dart' as helper;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteName.introduction);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: helper.cWhite,
      body: Center(child: Image.asset('assets/images/icon.png', width: 300)),
    );
  }
}
