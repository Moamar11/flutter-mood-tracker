import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/mood_entry.dart';

// =============================================================================
// MoodFacePainter
// =============================================================================

/// Draws a mood face directly on a [Canvas] using only Flutter's drawing
/// primitives (drawCircle, drawArc, drawPath, drawLine).
///
/// The face is always centered in [size] and scaled so that it fills the
/// available space while keeping the circle aspect ratio.
class MoodFacePainter extends CustomPainter {
  final MoodType mood;

  /// 0.0 → 1.0 animation progress (used when a timeline card is tapped).
  final double animationValue;

  MoodFacePainter({
    required this.mood,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;

    _drawFaceCircle(canvas, center, radius);
    _drawEyes(canvas, center, radius);
    _drawMouth(canvas, center, radius);

    // Mood-specific extras drawn on top.
    switch (mood) {
      case MoodType.ecstatic:
        _drawEyebrows(canvas, center, radius, angleOffset: -0.55);
        _drawCheeks(canvas, center, radius);
        break;
      case MoodType.happy:
        _drawEyebrows(canvas, center, radius, angleOffset: -0.3);
        break;
      case MoodType.neutral:
        _drawEyebrows(canvas, center, radius, angleOffset: 0.0);
        break;
      case MoodType.sad:
        _drawEyebrows(canvas, center, radius, angleOffset: 0.3);
        break;
      case MoodType.awful:
        _drawEyebrows(canvas, center, radius, angleOffset: 0.55);
        _drawTearDrop(canvas, center, radius);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Face circle
  // ---------------------------------------------------------------------------

  void _drawFaceCircle(Canvas canvas, Offset center, double radius) {
    final color = _faceColor;

    // Shadow glow.
    final shadowPaint = Paint()
      ..color = color.withAlpha(77)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, shadowPaint);

    // Face fill with radial gradient.
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Color.lerp(color, Colors.white, 0.45)!,
          color,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, fillPaint);

    // Outline.
    final strokePaint = Paint()
      ..color = color.withAlpha(179)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;
    canvas.drawCircle(center, radius, strokePaint);
  }

  // ---------------------------------------------------------------------------
  // Eyes
  // ---------------------------------------------------------------------------

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyeY = center.dy - radius * 0.18;
    final eyeOffsetX = radius * 0.32;
    final eyeRadius = radius * 0.12;

    final eyePaint = Paint()..color = const Color(0xFF263238);

    // For ecstatic: crescent/happy eyes (arcs).
    if (mood == MoodType.ecstatic) {
      _drawCrescentEye(canvas, Offset(center.dx - eyeOffsetX, eyeY), eyeRadius);
      _drawCrescentEye(canvas, Offset(center.dx + eyeOffsetX, eyeY), eyeRadius);
    } else if (mood == MoodType.awful) {
      // Draw X eyes for awful.
      _drawXEye(canvas, Offset(center.dx - eyeOffsetX, eyeY), eyeRadius);
      _drawXEye(canvas, Offset(center.dx + eyeOffsetX, eyeY), eyeRadius);
    } else {
      // Regular filled circles.
      canvas.drawCircle(
          Offset(center.dx - eyeOffsetX, eyeY), eyeRadius, eyePaint);
      canvas.drawCircle(
          Offset(center.dx + eyeOffsetX, eyeY), eyeRadius, eyePaint);

      // Highlight glints.
      final glintPaint = Paint()..color = Colors.white.withAlpha(200);
      final glintR = eyeRadius * 0.35;
      canvas.drawCircle(
          Offset(center.dx - eyeOffsetX - glintR * 0.5, eyeY - glintR * 0.5),
          glintR,
          glintPaint);
      canvas.drawCircle(
          Offset(center.dx + eyeOffsetX - glintR * 0.5, eyeY - glintR * 0.5),
          glintR,
          glintPaint);
    }
  }

  void _drawCrescentEye(Canvas canvas, Offset center, double radius) {
    // Draw a crescent using two overlapping arcs (^^ eyes).
    final paint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.7
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, math.pi, math.pi, false, paint);
  }

  void _drawXEye(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.5
      ..strokeCap = StrokeCap.round;
    final r = radius * 0.8;
    canvas.drawLine(
        center.translate(-r, -r), center.translate(r, r), paint);
    canvas.drawLine(
        center.translate(r, -r), center.translate(-r, r), paint);
  }

  // ---------------------------------------------------------------------------
  // Mouth
  // ---------------------------------------------------------------------------

  void _drawMouth(Canvas canvas, Offset center, double radius) {
    final mouthY = center.dy + radius * 0.28;
    final mouthHalfWidth = radius * 0.38;

    final paint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (mood) {
      case MoodType.ecstatic:
        // Wide open smile – large arc curving up.
        path.moveTo(center.dx - mouthHalfWidth * 1.1, mouthY - radius * 0.05);
        path.quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.42,
          center.dx + mouthHalfWidth * 1.1,
          mouthY - radius * 0.05,
        );
        // Fill to show teeth.
        final fillPath = Path()
          ..moveTo(center.dx - mouthHalfWidth * 1.1, mouthY - radius * 0.05)
          ..quadraticBezierTo(
            center.dx,
            mouthY + radius * 0.42,
            center.dx + mouthHalfWidth * 1.1,
            mouthY - radius * 0.05,
          )
          ..close();
        canvas.drawPath(
            fillPath,
            Paint()
              ..color = Colors.white.withAlpha(200)
              ..style = PaintingStyle.fill);
        canvas.drawPath(path, paint);
        break;

      case MoodType.happy:
        // Medium smile – gentle upward curve.
        path.moveTo(center.dx - mouthHalfWidth, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.28,
          center.dx + mouthHalfWidth,
          mouthY,
        );
        canvas.drawPath(path, paint);
        break;

      case MoodType.neutral:
        // Flat horizontal line.
        path.moveTo(center.dx - mouthHalfWidth, mouthY);
        path.lineTo(center.dx + mouthHalfWidth, mouthY);
        canvas.drawPath(path, paint);
        break;

      case MoodType.sad:
        // Downward curve (frown).
        path.moveTo(center.dx - mouthHalfWidth, mouthY + radius * 0.1);
        path.quadraticBezierTo(
          center.dx,
          mouthY - radius * 0.2,
          center.dx + mouthHalfWidth,
          mouthY + radius * 0.1,
        );
        canvas.drawPath(path, paint);
        break;

      case MoodType.awful:
        // Strong frown with wide spread.
        path.moveTo(center.dx - mouthHalfWidth * 1.1, mouthY + radius * 0.16);
        path.quadraticBezierTo(
          center.dx,
          mouthY - radius * 0.35,
          center.dx + mouthHalfWidth * 1.1,
          mouthY + radius * 0.16,
        );
        canvas.drawPath(path, paint);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Eyebrows
  // ---------------------------------------------------------------------------

  /// [angleOffset] positive = inner corners raised (sad/angry);
  /// negative = outer corners raised (happy/ecstatic).
  void _drawEyebrows(
    Canvas canvas,
    Offset center,
    double radius, {
    required double angleOffset,
  }) {
    final browY = center.dy - radius * 0.42;
    final offsetX = radius * 0.32;
    final halfWidth = radius * 0.22;
    final lift = radius * angleOffset * 0.28;

    final paint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    // Left eyebrow
    final leftPath = Path()
      ..moveTo(center.dx - offsetX - halfWidth, browY + lift)
      ..lineTo(center.dx - offsetX + halfWidth, browY - lift);
    canvas.drawPath(leftPath, paint);

    // Right eyebrow
    final rightPath = Path()
      ..moveTo(center.dx + offsetX - halfWidth, browY - lift)
      ..lineTo(center.dx + offsetX + halfWidth, browY + lift);
    canvas.drawPath(rightPath, paint);
  }

  // ---------------------------------------------------------------------------
  // Cheeks (ecstatic)
  // ---------------------------------------------------------------------------

  void _drawCheeks(Canvas canvas, Offset center, double radius) {
    final cheekY = center.dy + radius * 0.08;
    final cheekRadius = radius * 0.19;
    final cheekOffsetX = radius * 0.56;

    final paint = Paint()
      ..color = const Color(0xFFFF80AB).withAlpha(140)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
        Offset(center.dx - cheekOffsetX, cheekY), cheekRadius, paint);
    canvas.drawCircle(
        Offset(center.dx + cheekOffsetX, cheekY), cheekRadius, paint);
  }

  // ---------------------------------------------------------------------------
  // Tear drop (awful)
  // ---------------------------------------------------------------------------

  void _drawTearDrop(Canvas canvas, Offset center, double radius) {
    final tearX = center.dx + radius * 0.38;
    final tearTopY = center.dy - radius * 0.04;
    final tearSize = radius * 0.14;

    final path = Path()
      ..moveTo(tearX, tearTopY)
      ..cubicTo(
        tearX + tearSize,
        tearTopY + tearSize,
        tearX + tearSize,
        tearTopY + tearSize * 2,
        tearX,
        tearTopY + tearSize * 2.5,
      )
      ..cubicTo(
        tearX - tearSize,
        tearTopY + tearSize * 2,
        tearX - tearSize,
        tearTopY + tearSize,
        tearX,
        tearTopY,
      );

    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF64B5F6).withAlpha(200)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1565C0).withAlpha(150)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.025);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color get _faceColor {
    switch (mood) {
      case MoodType.ecstatic:
        return const Color(0xFFFFD740);
      case MoodType.happy:
        return const Color(0xFF66BB6A);
      case MoodType.neutral:
        return const Color(0xFF42A5F5);
      case MoodType.sad:
        return const Color(0xFF7E57C2);
      case MoodType.awful:
        return const Color(0xFFEF5350);
    }
  }

  @override
  bool shouldRepaint(MoodFacePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.animationValue != animationValue;
}

// =============================================================================
// MoodFaceWidget
// =============================================================================

/// Convenience widget that wraps [MoodFacePainter] inside a [CustomPaint].
class MoodFaceWidget extends StatelessWidget {
  final MoodType mood;
  final double size;
  final double animationValue;

  const MoodFaceWidget({
    super.key,
    required this.mood,
    this.size = 80,
    this.animationValue = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MoodFacePainter(
          mood: mood,
          animationValue: animationValue,
        ),
      ),
    );
  }
}
