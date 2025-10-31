import 'package:flutter/material.dart';

class BackButtonCommon extends StatelessWidget {
  final VoidCallback onPressed;
  final bool inline;
  final double topOffset;

  const BackButtonCommon({
    Key? key,
    required this.onPressed,
    this.inline = false,
    this.topOffset = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white.withOpacity(0.60),
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 32),
        onPressed: onPressed,
      ),
    );

    if (inline) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
        child: button,
      );
    } else {
      return Positioned(
        top: topOffset,
        left: 12.0,
        child: button,
      );
    }
  }
}
