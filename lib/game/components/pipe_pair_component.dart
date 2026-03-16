import 'dart:math';

import 'package:flutter/material.dart';

class PipePair {
  PipePair({
    required this.x,
    required this.gapCenter,
    required this.width,
    required this.gapHeight,
  });

  double x;
  double gapCenter;
  double width;
  double gapHeight;
  bool passed = false;

  Rect topRect(double groundHeight, double screenHeight) {
    final topHeight = max<double>(0.0, gapCenter - gapHeight / 2);
    return Rect.fromLTWH(x, 0, width, topHeight);
  }

  Rect bottomRect(double groundHeight, double screenHeight) {
    final bottomTop = gapCenter + gapHeight / 2;
    final bottomHeight = max<double>(
      0.0,
      screenHeight - groundHeight - bottomTop,
    );
    return Rect.fromLTWH(x, bottomTop, width, bottomHeight);
  }

  bool collidesWith(Rect birdRect, double groundHeight, double screenHeight) {
    return topRect(groundHeight, screenHeight).overlaps(birdRect) ||
        bottomRect(groundHeight, screenHeight).overlaps(birdRect);
  }

  void render(Canvas canvas, double groundHeight, double screenHeight) {
    final pipePaint = Paint()..color = const Color(0xFF2E7D32);
    final highlightPaint = Paint()..color = const Color(0xFF4CAF50);

    final top = topRect(groundHeight, screenHeight);
    final bottom = bottomRect(groundHeight, screenHeight);

    final topRRect = RRect.fromRectAndRadius(top, const Radius.circular(10));
    final bottomRRect = RRect.fromRectAndRadius(
      bottom,
      const Radius.circular(10),
    );

    canvas.drawRRect(topRRect, pipePaint);
    canvas.drawRRect(bottomRRect, pipePaint);

    final highlightWidth = width * 0.22;
    if (top.height > 0) {
      canvas.drawRect(
        Rect.fromLTWH(x + 6, 0, highlightWidth, top.height),
        highlightPaint,
      );
    }
    if (bottom.height > 0) {
      canvas.drawRect(
        Rect.fromLTWH(x + 6, bottom.top, highlightWidth, bottom.height),
        highlightPaint,
      );
    }
  }
}
