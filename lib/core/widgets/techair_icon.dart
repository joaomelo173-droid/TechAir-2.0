import 'package:flutter/material.dart';

enum TechAirIconType {
  compressor,
}

class TechAirIcon extends StatelessWidget {
  const TechAirIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.color,
  });

  final TechAirIconType type;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ?? IconTheme.of(context).color ?? Colors.white;

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: switch (type) {
          TechAirIconType.compressor => _CompressorIconPainter(
              color: resolvedColor,
            ),
        },
      ),
    );
  }
}

class _CompressorIconPainter extends CustomPainter {
  const _CompressorIconPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path(List<Offset> points, {bool close = false}) {
      final result = Path();

      if (points.isEmpty) return result;

      result.moveTo(
        points.first.dx * scale,
        points.first.dy * scale,
      );

      for (final point in points.skip(1)) {
        result.lineTo(
          point.dx * scale,
          point.dy * scale,
        );
      }

      if (close) result.close();

      return result;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          5.2 * scale,
          12.5 * scale,
          13.6 * scale,
          5.1 * scale,
        ),
        Radius.circular(2.5 * scale),
      ),
      stroke,
    );

    canvas.drawLine(
      Offset(7.2 * scale, 17.6 * scale),
      Offset(7.2 * scale, 19.2 * scale),
      stroke,
    );

    canvas.drawLine(
      Offset(16.8 * scale, 17.6 * scale),
      Offset(16.8 * scale, 19.2 * scale),
      stroke,
    );

    canvas.drawLine(
      Offset(5.8 * scale, 19.2 * scale),
      Offset(8.6 * scale, 19.2 * scale),
      stroke,
    );

    canvas.drawLine(
      Offset(15.4 * scale, 19.2 * scale),
      Offset(18.2 * scale, 19.2 * scale),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8.3 * scale,
          8.2 * scale,
          7.4 * scale,
          4.5 * scale,
        ),
        Radius.circular(1.1 * scale),
      ),
      stroke,
    );

    canvas.drawLine(
      Offset(10 * scale, 8.2 * scale),
      Offset(10 * scale, 6.7 * scale),
      stroke,
    );

    canvas.drawLine(
      Offset(14 * scale, 8.2 * scale),
      Offset(14 * scale, 6.7 * scale),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          9.2 * scale,
          4.7 * scale,
          2 * scale,
          2.2 * scale,
        ),
        Radius.circular(.5 * scale),
      ),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          12.8 * scale,
          4.7 * scale,
          2 * scale,
          2.2 * scale,
        ),
        Radius.circular(.5 * scale),
      ),
      stroke,
    );

    canvas.drawPath(
      path([
        const Offset(8.3, 10.1),
        const Offset(6.5, 10.1),
        const Offset(5.2, 11.4),
        const Offset(5.2, 13.2),
      ]),
      stroke,
    );

    canvas.drawPath(
      path([
        const Offset(15.7, 10.1),
        const Offset(17.5, 10.1),
        const Offset(18.8, 11.4),
        const Offset(18.8, 13.2),
      ]),
      stroke,
    );

    canvas.drawCircle(
      Offset(12 * scale, 10.45 * scale),
      .85 * scale,
      fill,
    );

    canvas.drawLine(
      Offset(12 * scale, 12.7 * scale),
      Offset(12 * scale, 14.4 * scale),
      stroke,
    );

    canvas.drawCircle(
      Offset(12 * scale, 15.2 * scale),
      .45 * scale,
      fill,
    );

    canvas.drawArc(
      Rect.fromLTWH(
        2.7 * scale,
        2.8 * scale,
        18.6 * scale,
        18.6 * scale,
      ),
      3.65,
      2.12,
      false,
      stroke,
    );

    canvas.drawArc(
      Rect.fromLTWH(
        4.4 * scale,
        4.5 * scale,
        15.2 * scale,
        15.2 * scale,
      ),
      3.72,
      1.98,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _CompressorIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}