import 'package:flutter/material.dart';

class CyberSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const CyberSpinner({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        // Defaults to your Cyberpunk Crimson if no color is provided
        color: color ?? Theme.of(context).colorScheme.primary,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round, // Makes the spinner edges rounded and modern
      ),
    );
  }
}