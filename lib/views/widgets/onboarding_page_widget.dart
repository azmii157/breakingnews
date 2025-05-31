// import 'package:flutter/material.dart';
// import '../utils/helper.dart' as helper;

// class OnboardingPageWidget extends StatelessWidget {
//   final String imageAsset;
//   final String title;
//   final String description;

//   const OnboardingPageWidget({
//     super.key,
//     required this.imageAsset,
//     required this.title,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = helper.screenHeight(context);

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Image.asset(
//             imageAsset,
//             height: screenHeight * 0.35,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 height: screenHeight * 0.35,
//                 color: helper.cGrey,
//                 child: Center(
//                   child: Text(
//                     'Image not found',
//                     style: helper.subtitle2.copyWith(color: helper.cTextBlue),
//                   ),
//                 ),
//               );
//             },
//           ),
//           helper.vsLarge,
//           Text(
//             title,
//             textAlign: TextAlign.left,
//             style: helper.headline3.copyWith(
//               color: helper.cBlack,
//               fontWeight: helper.bold,
//             ),
//           ),
//           helper.vsMedium,
//           Text(
//             description,
//             textAlign: TextAlign.center,
//             style: helper.subtitle1.copyWith(
//               color: helper.cTextBlue,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
