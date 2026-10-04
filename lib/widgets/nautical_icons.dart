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

    // Iç daire
    final innerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), r * 0.65, innerPaint);

    // Pusula çizgileri (kuzey-güney)
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;

    // Kuzey ibresi (turuncu)
    final northPaint = Paint()
      ..color = accent
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy - r * 0.7), Offset(cx, cy), northPaint);
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + r * 0.7), linePaint);

    // Doğu-batı çizgisi
    final sidePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - r * 0.7, cy), Offset(cx + r * 0.7, cy), sidePaint);

    // Merkez nokta
    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.045, dotPaint);

    // Yön harfleri
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

/// Çapa ikonu - denizcilik demirleme sembolu
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

    // Üst halka
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;
    canvas.drawCircle(Offset(cx, size.height * 0.15), size.width * 0.09, ringPaint);

    // Dikey gövde
    canvas.drawLine(
      Offset(cx, size.height * 0.24),
      Offset(cx, size.height * 0.82),
      paint,
    );

    // Yatay çubuk (stock)
    canvas.drawLine(
      Offset(cx - size.width * 0.28, size.height * 0.32),
      Offset(cx + size.width * 0.28, size.height * 0.32),
      paint,
    );

    // Alt kanca (sol)
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;

    final leftArc = Rect.fromCircle(center: Offset(cx - size.width * 0.18, size.height * 0.72), radius: size.width * 0.18);
    canvas.drawArc(leftArc, 0, 3.14, false, arcPaint);

    final rightArc = Rect.fromCircle(center: Offset(cx + size.width * 0.18, size.height * 0.72), radius: size.width * 0.18);
    canvas.drawArc(rightArc, 0, 3.14, false, arcPaint);

    // Kanca uçları
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

/// Dümen (helm) ikonu - gemi dümen sembolu
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

    // Dış halka
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;
    canvas.drawCircle(Offset(cx, cy), r, ringPaint);

    // İç daire (dümen merkezi)
    final hubPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, hubPaint);

    final hubRing = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.10, hubRing);

    // 6 tutamak (kollar)
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

      // Tutamak uçlarında küçük yuvarlak
      final knobPaint = Paint()..color = color;
      canvas.drawCircle(Offset(x2, y2), size.width * 0.025, knobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
