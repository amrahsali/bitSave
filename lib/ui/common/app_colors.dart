import 'package:flutter/material.dart';

const Color kcPrimaryColor = Color(0xFF432E9D);
const Color kcFadeColor = Color.fromRGBO(14, 41, 84, 0.1);
const Color kcSecondaryColor = Color(0xFFCC9933);
const Color kcStarColor = Color(0xFFFDCC0D);
const Color kcOrangeColor = Color(0xFFFFB000);
const Color kcWhiteColor = Color(0xFFFFFFFF);
const Color kcBlackColor = Color(0xFF000000);
const Color kcDarkGreyColor = Color(0xFF1A1B1E);
const Color kcMediumGrey = Color(0xFF474A54);
const Color kcLightGrey = Color(0xFFFAFAFA);
const Color kcOrange = Color(0xFFDD6700);
const Color kcBackgroundColor = Color(0xFFFFF3DB);

const BoxDecoration kcGradientDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF432E9D),
      Colors.black,
    ],
  ),
);

LinearGradient get kcAppBackgroundGradient => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    kcPrimaryColor, // purple
    kcBlackColor,    // black
  ],
);

LinearGradient get kcCardGradient => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    kcPrimaryColor.withOpacity(0.8),
    kcPrimaryColor,
  ],
);

// Light theme background
Color get kcLightBackground => kcWhiteColor;

// Dark theme background (use gradient)
BoxDecoration get kcDarkBackgroundDecoration => BoxDecoration(
  gradient: kcAppBackgroundGradient,
);

BoxDecoration get kcLightBackgroundDecoration => BoxDecoration(
  color: kcLightBackground,
);

LinearGradient kcCustomOnboardingGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    const Color(0xFF110C1D).withOpacity(0.0),
    const Color(0xFF110C1D),
  ],
);


final List<Color> kcAvatarColors = [
  Color(0xFFF44336),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF673AB7),
  Color(0xFF3F51B5),
  Color(0xFF2196F3),
  Color(0xFF03A9F4),
  Color(0xFF00BCD4),
  Color(0xFF009688),
  Color(0xFF4CAF50),
  Color(0xFF8BC34A),
  Color(0xFFCDDC39),
  Color(0xFFFFC107),
  Color(0xFFFF9800),
  Color(0xFFFF5722),
];