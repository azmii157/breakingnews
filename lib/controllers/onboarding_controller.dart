// import 'package:flutter/material.dart';

// class OnboardingInfo {
//   final String imageAsset;
//   final String title;
//   final String description;

//   OnboardingInfo({
//     required this.imageAsset,
//     required this.title,
//     required this.description,
//   });
// }

// class OnboardingController with ChangeNotifier {
//   final PageController pageController = PageController();
//   int _currentPage = 0;

//   int get currentPage => _currentPage;
//   final List<OnboardingInfo> onboardingPages = [
//     OnboardingInfo(
//       imageAsset: 'assets/img intro 1.png',
//       title: 'The World at Your Fingertips',
//       description:
//           'Get 24/7 updates on global news from breaking politics to cultural trends, all in one place.',
//     ),
//     OnboardingInfo(
//       imageAsset: 'assets/img intro 2.png',
//       title: 'Tailored to Your Curiosity',
//       description:
//           'Personalize your news feed. Discover stories that matter to you, from technology to sports.',
//     ),
//     OnboardingInfo(
//       imageAsset: 'assets/img intro 3.png',
//       title: 'Trusted Updates in Real-Time',
//       description:
//           'Stay informed with verified news, delivered instantly as events unfold around the globe.',
//     ),
//   ];

//   void onPageChanged(int index) {
//     _currentPage = index;
//     notifyListeners();
//   }
 
//   void nextPageAction(BuildContext context) {
//     if (_currentPage < onboardingPages.length - 1) {
//       pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       debugPrint("Onboarding Selesai! Navigasi ke halaman berikutnya...");
//     }
//   }

//   void skipOnboardingAction(BuildContext context) {
//     debugPrint("Skip Onboarding! Navigasi ke halaman berikutnya...");
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }
// }
