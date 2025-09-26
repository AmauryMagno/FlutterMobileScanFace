import 'package:flutter/material.dart';

class Camera extends StatelessWidget {
  final String title;
  final Color color;

  const Camera({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(51),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
