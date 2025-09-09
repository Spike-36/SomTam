import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String imageAsset;          // can be '' if no background wanted
  final double blueOverlayOpacity;  // 0.0–1.0
  final Alignment alignment;

  const AppBackground({
    super.key,
    required this.child,
    this.imageAsset = '', // default to empty = no background
    this.blueOverlayOpacity = 0.75,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image (only if provided)
        if (imageAsset.isNotEmpty)
          Positioned.fill(
            child: Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.high,
            ),
          ),

        // Blue overlay (solid color if opacity=1.0)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: const Color.fromRGBO(0, 101, 189, 1.0)
                  .withOpacity(blueOverlayOpacity),
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(
          child: SafeArea(child: child),
        ),
      ],
    );
  }
}
