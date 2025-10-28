import 'package:flutter/material.dart';

/// Floating Home icon overlay.
/// - White outlined home icon on dark translucent circular background
/// - Default: top 20, left 20 (below app bar area)
/// - Small: 44x44 circle, 24px icon
class HomeButtonOverlay extends StatelessWidget {
  final VoidCallback? onTap;
  final double top;
  final double left;

  const HomeButtonOverlay({
    super.key,
    this.onTap,
    this.top = 20,
    this.left = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('🏠 Overlay gesture detected');
          onTap?.call();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.home_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
