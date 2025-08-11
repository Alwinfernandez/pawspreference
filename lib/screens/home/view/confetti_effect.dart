import 'package:flutter/material.dart';

// draws confetti particles
class ConfettiEffect extends CustomPainter {
  final List<Offset> positions;
  final List<Color> colors;

  ConfettiEffect(this.positions, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < positions.length; i++) {
      paint.color = colors[i];
      canvas.drawCircle(positions[i], 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
