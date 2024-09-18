// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // main colors of the app
    dividerColor: Colors.grey[300],
    fontFamily: 'Roboto',
    primaryColor: Colors.teal,
    primaryColorLight: Colors.tealAccent,
    primaryColorDark: Colors.teal,
    disabledColor: Colors.grey,
    // ripple color
    splashColor: Colors.teal,
    // card view theme
    cardTheme: CardTheme(
        color: Colors.white, shadowColor: Colors.grey, elevation: 4.0),
    // App bar theme
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      color: Colors.teal,
      shadowColor: Colors.grey,
      titleTextStyle: TextStyle(
          fontSize: 22.0, fontWeight: FontWeight.w800, color: Colors.white),
      iconTheme: IconThemeData(
        color: Colors.white, // Set the back arrow color to white globally
      ),
    ),
  );
}
