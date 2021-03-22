import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  CustomButton({required this.onPressed, required this.child});

  final GestureTapCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: ElevatedButton(
          child: child,
          onPressed: onPressed,
        ));
  }
}
