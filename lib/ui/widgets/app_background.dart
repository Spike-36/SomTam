import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String imageAsset;          // e.g. 'assets/images/brawHome.jpg'
  final double blueOverlayOpacity;  // 0.0–1.0
  final Alignment alignment;

  const AppBackground({
    super.key,
    required this.child,
    required this.imageAsset,
    this.blueOverlayOpacity = 0.75, // match Braw2 default
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            alignment: alignment,
            filterQuality: FilterQuality.high,
          ),
        ),

        // Blue overlay from Braw2: rgb(0,101,189)
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
