import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//* Color
Color cPrimary = const Color(0xff2D336B);
Color cTextBlue = const Color(0xff4E4B66);
Color cLinear = const Color(0xffA9B5DF);
Color cBlack = const Color(0xff000000);
Color cWhite = const Color(0xffFFFFFF);
Color cGrey = const Color(0xffF1F1F5);
Color cError = const Color(0xffFF4545);
Color cSuccess = const Color(0xff007360);
const Color cwhite = Colors.white;
//* Space /Color.fromARGB(255, 85, 60, 62) 47, 61) horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget hsSuperTiny = SizedBox(width: 4.0);
const Widget hsTiny = SizedBox(width: 8.0);
const Widget hsSmall = SizedBox(width: 12.0);
const Widget hsMedium = SizedBox(width: 16.0);
const Widget hsLarge = SizedBox(width: 24.0);
const Widget hsXLarge = SizedBox(width: 36.0);
const Widget hsMassive = SizedBox(width: 120.0);
const Widget vsSuperTiny = SizedBox(height: 4.0);
const Widget vsTiny = SizedBox(height: 8.0);
const Widget vsSmall = SizedBox(height: 12.0);
const Widget vsMedium = SizedBox(height: 16.0);
const Widget vsLarge = SizedBox(height: 24.0);
const Widget vsXLarge = SizedBox(height: 36.0);
const Widget vsMassive = SizedBox(height: 120.0);
//* Divider
Widget spacedDivider = Column(
  children: <Widget>[
    vsTiny,
    vsTiny,
    Divider(color: cLinear, height: 4.0),
    vsTiny,
    vsTiny,
  ],
);
//* Screen
Widget verticalSpace(double height) => SizedBox(height: height);
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
//* Font Weight
FontWeight thin = FontWeight.w100;
FontWeight extralight = FontWeight.w200;
FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
FontWeight extrabold = FontWeight.w800;
//* TextStyle
TextStyle headline1 = GoogleFonts.poppins(fontSize: 40);
TextStyle headline2 = GoogleFonts.poppins(fontSize: 34);
TextStyle headline3 = GoogleFonts.poppins(fontSize: 24);
TextStyle headline4 = GoogleFonts.poppins(fontSize: 20);
TextStyle subtitle1 = GoogleFonts.poppins(fontSize: 16);
TextStyle subtitle2 = GoogleFonts.poppins(fontSize: 14);
TextStyle caption = GoogleFonts.poppins(fontSize: 12);
TextStyle overline = GoogleFonts.poppins(fontSize: 10);
//* Border
OutlineInputBorder enableBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cBlack),
  borderRadius: BorderRadius.circular(5),
);
OutlineInputBorder focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cPrimary),
  borderRadius: BorderRadius.circular(5),
);
OutlineInputBorder errorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cError),
  borderRadius: BorderRadius.circular(5),
);
OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: cError),
  borderRadius: BorderRadius.circular(5),
);
//* Box Decorations
BoxDecoration fieldDecortaion = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.grey[200],
);
BoxDecoration disabledFieldDecortaion = BoxDecoration(
  borderRadius: BorderRadius.circular(5),
  color: Colors.grey[100],
);
//* Field Variables
const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets largeFieldPadding = EdgeInsets.symmetric(
  horizontal: 15,
  vertical: 15,
);
