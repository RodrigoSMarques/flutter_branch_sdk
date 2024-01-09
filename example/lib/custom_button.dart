import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.child});

  final GestureTapCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
        ));
  }
}
