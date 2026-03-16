import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BirdComponent extends PositionComponent {
  BirdComponent({required this.sprite}) {
    size = Vector2(46, 34);
    anchor = Anchor.center;
  }

  final Sprite sprite;
  double velocity = 0;

  Rect get hitbox {
    final hitWidth = size.x * 0.72;
    final hitHeight = size.y * 0.72;
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: hitWidth,
      height: hitHeight,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final diameter = size.x < size.y ? size.x : size.y;
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: diameter,
      height: diameter,
    );
    final clip = Path()..addOval(rect);

    canvas.save();
    canvas.clipPath(clip);
    sprite.renderRect(canvas, rect);
    canvas.restore();

    final borderPaint = Paint()
      ..color = const Color(0xFFFACC15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(rect, borderPaint);
  }
}
