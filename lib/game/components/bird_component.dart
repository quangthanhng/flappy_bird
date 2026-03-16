import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BirdComponent extends PositionComponent {
  BirdComponent() {
    size = Vector2(46, 34);
    anchor = Anchor.center;
  }

  double velocity = 0;

  Rect get hitbox {
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bodyPaint = Paint()..color = const Color(0xFFF7D21F);
    final bellyPaint = Paint()..color = const Color(0xFFFDE68A);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black87;
    final beakPaint = Paint()..color = const Color(0xFFF59E0B);

    final bodyRect = Rect.fromLTWH(-size.x / 2, -size.y / 2, size.x, size.y);
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(12),
    );

    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -size.x / 2 + 6,
          -size.y / 2 + 10,
          size.x - 14,
          size.y / 2,
        ),
        const Radius.circular(10),
      ),
      bellyPaint,
    );

    canvas.drawCircle(const Offset(8, -4), 6, eyePaint);
    canvas.drawCircle(const Offset(10, -4), 3, pupilPaint);

    final beakPath = Path()
      ..moveTo(size.x / 2 - 2, 0)
      ..lineTo(size.x / 2 + 10, 4)
      ..lineTo(size.x / 2 - 2, 8)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }
}
