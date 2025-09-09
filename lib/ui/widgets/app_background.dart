import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? imageAsset;          // null => no background image
  final double blueOverlayOpacity;   // 0.0–1.0
  final Alignment alignment;

  const AppBackground({
    super.key,
    required this.child,
    this.imageAsset,                 // ← optional now
    this.blueOverlayOpacity = 0.75,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // load only if provided
        if (imageAsset != null && imageAsset!.isNotEmpty)
          Positioned.fill(
            child: Image.asset(
              imageAsset!,
              fit: BoxFit.cover,
              alignment: alignment,
              filterQuality: FilterQuality.high,
            ),
          ),

        // Blue overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: const Color(0xFF0047A0).withOpacity(blueOverlayOpacity),
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(child: SafeArea(child: child)),
      ],
    );
  }
}
