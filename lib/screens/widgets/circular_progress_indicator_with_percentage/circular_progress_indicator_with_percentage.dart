import 'package:flutter/material.dart';

class CircularProgressIndicatorWithPercentage extends StatelessWidget {
  final double percentage;
  final double strokeWidth;
  final double size;
  final Color foregroundColor;
  final Color? backgroundColor;
  final Widget? child;

  const CircularProgressIndicatorWithPercentage({
    required this.percentage,
    required this.strokeWidth,
    required this.size,
    required this.foregroundColor,
    this.backgroundColor,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          percentage: percentage,
          strokeWidth: strokeWidth,
          foregroundColor: foregroundColor,
          backGroundColor: backgroundColor ?? foregroundColor.withOpacity(0.2),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color foregroundColor;
  final Color backGroundColor;

  _CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.foregroundColor,
    required this.backGroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backGroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    const startAngle = -90 * 3.1415927 / 180;
    final sweepAngle = 2 * 3.1415927 * (percentage / 100);

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
