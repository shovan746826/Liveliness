import 'package:flutter/material.dart';

class ColorConfig {

  static const Color primaryColor = Color(0xff11102F);
  static const Color secondaryColor = Color(0xE400265C);

  static const Color accentColor = Color(0xFF2E5DFF);

  static const String secondaryColorString = "#2F89FC";

  static const Color backgroundColorPrimary = Color(0xffFBFBFB);
  static const Color backgroundColorSecondary = Color(0xffE7F0F4);
  static const Color backgroundColorDark = Color(0xFF141933);
  static const Color backgroundColorNumberPad = Color(0xFFF2FFFA);
  static const Color onboardingBackgroundColor = Color(0xFFFAF4E3);

  static const Color sectionButtonIconBgColor = Color(0xffFAFAFA);

  static const Color textColorPrimary = Color(0xff11102F);
  static const Color textColorSecondary = Color(0xE400265C);
  static const Color textColorDark = Color(0xFF000000);
  static const Color textColorGray = Color(0xff7B7B7B);
  static const Color textLabelColor = Color(0xff717E95);

  static const Color borderColor = Color(0x73b8b8b8);

  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color redColor = Color(0xFFEE1200);
  static const Color pinkColor = Color(0xFFE500FF);
  static const Color orangeColor = Color(0xFFFF7648);
  static const Color yellowColor = Color(0xFFF4ED48);
  static const Color blueColor = Color(0xFF03D4FF);
  static const Color goldColor = Color(0xE4FFA300);
  static const Color greyColor = Color(0xffB8B8B8);
  static const Color greyLightColor = Color(0xffefefef);
  static const Color greenColor = Color(0xFF4BC03C);
  static const Color circleStrokeWidth = Color(0xFF09FBD3);
  static const Color deepGreen = Color(0xff034931);




  static var shadowColor = const Color(0xff38CFFF).withOpacity(0.1);
  static var dividerColor = const Color(0xff4754C5);



  static const Color blackColor = Color(0xff000000);




  static var backgroundGradientColor_1 = const Color(0xff000000);
  static var backgroundGradientColor_2 = const Color(0xff11102F);
  static var backgroundGradientColor_3 = const Color(0xE400265C);
  static var backgroundGradientColorGold = const Color(0xE4FFA300);

  static Gradient backgroundGradientColor =  LinearGradient(
    colors: [
      backgroundGradientColor_1,
      backgroundGradientColor_2,
      backgroundGradientColor_3,
      backgroundGradientColor_2,
      backgroundGradientColor_1,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );




  static Gradient lineGradientColor =  const LinearGradient(
    colors: [
      Color(0xff35228E),
      Color(0xb335228e),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Gradient goldenGradientColor = const LinearGradient(
    colors: [
      Color.fromRGBO(255, 249, 215, 1), // Gold
      Color.fromRGBO(85, 0, 9, 1),     // Dark Red
      Color.fromRGBO(255, 237, 132, 1) // Light Yellow
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );


  static const Gradient pieChartGradientColor = SweepGradient(
    colors: [
      Color(0xff3B82F6),
      Color(0xffA855F7),
      Color(0xffEC4899),
      Color(0xff3B82F6),
    ],
    startAngle: 0.0,
    endAngle: 3.14159 * 2, // full circle
    transform: GradientRotation(-3.14159 / 2), // start from top (optional)
  );

  static Gradient selectedButtonGradientColor =  const LinearGradient(
    colors: [

      Color.fromRGBO(43, 61, 141, 1),
      Color.fromRGBO(12, 17, 39, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static var transparentColor = const Color(0x00000000);
}

/*
Primary : #35228E
Secendory : #2F89FC
Light Sky : #B0DAFF
Black : #170000
White : #FFFFFF
Gray : #F8F8F8
Deep Gray : #CCCCCC
Red : #ED1C22
Yello : #FEC907
Green : #7CBB15
Sky Deep : #30ADE5
Light Gray : #FDF8EA
*/

