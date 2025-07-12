import 'package:flutter/material.dart';
class AppWidget{
  // This class can be used to provide common widget support methods
  // or properties that can be used across the app.
  
  // Example method to get a themed text style
  static TextStyle getPlaywriteOrangeTitleTextStyle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
      fontFamily: 'PlaywriteGBS',
    );
  }
  static TextStyle getPlayLargeOrangeTextStyle() {
    return const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
      fontFamily: 'PlaywriteGBS',
    );
  }
   static TextStyle getPlaywriteBlackTitleTextStyle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      fontFamily: 'PlaywriteGBS',
    );
  }
   static TextStyle getPoppinsOrangeHeaderTextStyle() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
      fontFamily: 'Poppins',
    );
  }
    static TextStyle getPoppinsOrangeSmallHeaderTextStyle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
      fontFamily: 'Poppins',
    );
  }
   static TextStyle getPoppinsBlackSmallHeaderTextStyle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      fontFamily: 'Poppins',
    );
  }
    static TextStyle getPoppinsOrangeLightTextStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.orangeAccent,
      fontFamily: 'Poppins',
    );
  }
  static TextStyle getPoppinsBlackLightTextStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
      fontFamily: 'Poppins',
    );
  }
   static TextStyle getBoldBlackHeadingTextStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      // fontFamily: 'Poppins',
    );
  }
   static TextStyle getBlackLightHeadingTextStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
      // fontFamily: 'Poppins',
    );
  }
   static TextStyle getPoppinsWhiteHeadingTextStyle() {
    return const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontFamily: 'Poppins',
    );
  }
  static Color getPrimaryColor() {
    return Colors.deepOrange;
  }
    static Widget customButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    double heightFactor = 0.35,
    double widthFactor = 0.12,
    Color backgroundColor = Colors.deepOrange,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          fixedSize: Size(
            MediaQuery.of(context).size.height * heightFactor,
            MediaQuery.of(context).size.width * widthFactor,
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            // fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // Example method to get a themed button style
  // static ButtonStyle getPrimaryButtonStyle() {
  //   return ElevatedButton.styleFrom(
  //     primary: Colors.deepOrange,
  //     onPrimary: Colors.white,
  //   );
  }
  
  
