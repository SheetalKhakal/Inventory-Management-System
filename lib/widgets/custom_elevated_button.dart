// ignore_for_file: use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double width; // Add width parameter
  final Color backgroundColor; // Add background color parameter
  final Color borderColor; // Add border color parameter
  final Color textColor; // Add text color parameter

  CustomElevatedButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.width = double.infinity, // Default width to full width
    Color? backgroundColor, // No default here
    this.borderColor = Colors.transparent, // Default border color
    this.textColor = Colors.white, // Default text color
  })  : backgroundColor =
            backgroundColor ?? Colors.teal, // Set default in initializer
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Use the provided width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
              backgroundColor), // Dynamic background color
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                  color: borderColor, width: 2.0), // Dynamic border color
            ),
          ),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
