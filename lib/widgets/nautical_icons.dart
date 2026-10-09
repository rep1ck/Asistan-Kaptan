import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pusula ikonu - denizcilik navigasyon sembolu
class CompassIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color? accentColor;

  const CompassIcon({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF5CE1E6),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(color, accentColor ?? const Color(0xFFFF8A00)),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final Color color;
  final Color accent;

  _CompassPainter(this.color, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;

    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    final innerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), r * 0.65, innerPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    final northPaint = Paint()
      ..color = accent
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy - r * 0.7), Offset(cx, cy), northPaint);
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + r * 0.7), linePaint);

    final sidePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - r * 0.7, cy), Offset(cx + r * 0.7, cy), sidePaint);

    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.045, dotPaint);

    final textStyle = TextStyle(
      color: color,
      fontSize: size.width * 0.12,
      fontWeight: FontWeight.bold,
    );
    _drawText(canvas, 'N', Offset(cx - size.width * 0.035, cy - r - size.width * 0.14), textStyle.copyWith(color: accent));
    _drawText(canvas, 'S', Offset(cx - size.width * 0.03, cy + r + size.width * 0.02), textStyle);
    _drawText(canvas, 'E', Offset(cx + r + size.width * 0.02, cy - size.width * 0.06), textStyle);
    _drawText(canvas, 'W', Offset(cx - r - size.width * 0.10, cy - size.width * 0.06), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Çapa ikonu
class AnchorIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AnchorIcon({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF5CE1E6),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AnchorPainter(color)),
    );
  }
}

class _AnchorPainter extends CustomPainter {
  final Color color;

  _AnchorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;
    canvas.drawCircle(Offset(cx, size.height * 0.15), size.width * 0.09, ringPaint);

    canvas.drawLine(
      Offset(cx, size.height * 0.24),
      Offset(cx, size.height * 0.82),
      paint,
    );

    canvas.drawLine(
      Offset(cx - size.width * 0.28, size.height * 0.32),
      Offset(cx + size.width * 0.28, size.height * 0.32),
      paint,
    );

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final leftArc = Rect.fromCircle(center: Offset(cx - size.width * 0.18, size.height * 0.72), radius: size.width * 0.18);
    canvas.drawArc(leftArc, 0, 3.14, false, arcPaint);

    final rightArc = Rect.fromCircle(center: Offset(cx + size.width * 0.18, size.height * 0.72), radius: size.width * 0.18);
    canvas.drawArc(rightArc, 0, 3.14, false, arcPaint);

    canvas.drawLine(
      Offset(cx - size.width * 0.36, size.height * 0.72),
      Offset(cx - size.width * 0.36, size.height * 0.64),
      paint,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.36, size.height * 0.72),
      Offset(cx + size.width * 0.36, size.height * 0.64),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dümen (helm) ikonu
class HelmIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color? accentColor;

  const HelmIcon({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF5CE1E6),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HelmPainter(color, accentColor ?? const Color(0xFFFF8A00))),
    );
  }
}

class _HelmPainter extends CustomPainter {
  final Color color;
  final Color accent;

  _HelmPainter(this.color, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;
    canvas.drawCircle(Offset(cx, cy), r, ringPaint);

    final hubPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, hubPaint);

    final hubRing = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.10, hubRing);

    final spokePaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;

    final spokeCount = 6;
    for (var i = 0; i < spokeCount; i++) {
      final angle = (i * 2 * math.pi) / spokeCount;
      final inner = size.width * 0.12;
      final outer = r + size.width * 0.05;
      final x1 = cx + inner * math.cos(angle);
      final y1 = cy + inner * math.sin(angle);
      final x2 = cx + outer * math.cos(angle);
      final y2 = cy + outer * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), spokePaint);

      final knobPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x2, y2), size.width * 0.025, knobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gemi / AIS işareti — COG yönünde dönen ok ucu (üçgen).
/// [headingDeg] null ise kuzeye bakar.
class ShipTriangleIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double? headingDeg;
  final bool filled;

  const ShipTriangleIcon({
    super.key,
    this.size = 28,
    this.color = const Color(0xFF2DD4DF),
    this.headingDeg,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final angle = ((headingDeg ?? 0) * math.pi / 180);
    return SizedBox(
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angle,
        child: CustomPaint(
          painter: _ShipTrianglePainter(color, filled),
        ),
      ),
    );
  }
}

class _ShipTrianglePainter extends CustomPainter {
  final Color color;
  final bool filled;

  _ShipTrianglePainter(this.color, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Ok ucu: üstte sivri (pruva), altta geniş taban (kıç)
    final path = Path()
      ..moveTo(w * 0.5, h * 0.06)
      ..lineTo(w * 0.92, h * 0.92)
      ..lineTo(w * 0.5, h * 0.72)
      ..lineTo(w * 0.08, h * 0.92)
      ..close();

    if (filled) {
      final fill = Paint()
        ..color = color.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fill);
    }

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.06)
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, stroke);

    final tip = Paint()..color = color;
    canvas.drawCircle(Offset(w * 0.5, h * 0.08), w * 0.04, tip);
  }

  @override
  bool shouldRepaint(covariant _ShipTrianglePainter old) =>
      old.color != color || old.filled != filled;
}
