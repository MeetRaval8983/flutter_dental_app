import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    this.buttonText,
    this.onTap,
    this.color,
    this.textColor,
    this.icon,
  });

  final String? buttonText;
  final Widget? onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon; // <-- Add icon here

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (e) => onTap!,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: color!,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(
                  icon,
                  color: textColor!,
                  size: 24,
                ),
              ),
            Text(
              buttonText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: textColor!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
