import 'dart:math';

import 'package:flutter/material.dart';

class ChartData {
  final String category;
  final double value;
  final Color color;
  final TextStyle? textStyle;

  ChartData({
    required this.category,
    required this.value,
    required this.color,

    this.textStyle,
  });
}

class PieChartOptions {
  final double? width;
  final double? height;
  final double shadowHeight;
  final double ellipseRatio;
  final double depthDarkness;
  final bool showLabels;
  final TextStyle defaultTextStyle;
  final double radius;

  PieChartOptions({
    this.width = 300,
    this.height = 300,
    this.shadowHeight = 20.0,
    this.ellipseRatio = 0.8,
    this.depthDarkness = 0.3,
    this.showLabels = true,
    this.radius = 0.45,
    TextStyle? defaultTextStyle,
  }) : defaultTextStyle = defaultTextStyle ??
      const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
}

class ThreeDPieChart extends StatelessWidget {
  final List<ChartData> data;
  final PieChartOptions options;

  ThreeDPieChart({super.key,
    required this.data,
    PieChartOptions? options,
  }) : options = options ?? PieChartOptions();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: options.width,
      height: options.height,
      child: CustomPaint(
        painter: ThreeDPieChartPainter(
          data,
          options,
        ),
      ),
    );
  }
}

class ThreeDPieChartPainter extends CustomPainter {
  final List<ChartData> chartData;
  final PieChartOptions options;

  ThreeDPieChartPainter(this.chartData, this.options);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * options.radius;
    final depthOffset = options.shadowHeight ;
    final double total = chartData.fold(0.0, (sum, item) => sum + item.value);
    double currentAngle = -pi / 2;

    // Draw depth sides for all slices
    for (var data in chartData) {
      final sweepAngle = (data.value / total) * 2 * pi;
      final startAngle = currentAngle;
      final endAngle = currentAngle + sweepAngle;

      final topArcRect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2 * options.ellipseRatio,
      );
      final bottomArcRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + depthOffset),
        width: radius * 2,
        height: radius * 2 * options.ellipseRatio,
      );

      final depthPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = darkenColor(data.color, options.depthDarkness);

      final path = Path();

      // Check if slice includes leftmost (π) or rightmost (0) edges
      bool includesPi = startAngle < pi && endAngle > pi;
      bool includesZero = startAngle < 0 && endAngle > 0;

      if (includesPi) {
        // Handle leftmost slice (π)
        _drawSplitDepthPath(
          path,
          topArcRect,
          bottomArcRect,
          startAngle,
          endAngle,
          pi,
          center,
          radius,
          depthOffset,
          options.ellipseRatio,
        );
      } else if (includesZero) {

        // Handle rightmost slice (0)
        _drawSplitDepthPath(
          path,
          topArcRect,
          bottomArcRect,
          startAngle,
          endAngle,
          0,
          center,
          radius,
          depthOffset,
          options.ellipseRatio,
        );
      } else {
        // Draw curved depth side for other slices
        path
          ..moveTo(
            center.dx + radius * cos(startAngle),
            center.dy + (radius * options.ellipseRatio) * sin(startAngle),
          )
          ..lineTo(
            center.dx + radius * cos(startAngle),
            center.dy +
                depthOffset +
                (radius * options.ellipseRatio) * sin(startAngle),
          )
          ..arcTo(bottomArcRect, startAngle, sweepAngle, false)
          ..lineTo(
            center.dx + radius * cos(endAngle),
            center.dy + (radius * options.ellipseRatio) * sin(endAngle),
          )
          ..arcTo(topArcRect, endAngle, -sweepAngle, false)
          ..close();}

      canvas.drawPath(path, depthPaint);
      currentAngle = endAngle;
    }

    //Draw top pie slices
    currentAngle = -pi / 2;
    for (var data in chartData) {
      final sweepAngle = (data.value / total) * 2 * pi;
      final midAngle = currentAngle + sweepAngle / 2;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = data.color;

      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2 * options.ellipseRatio,
        ),
        currentAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw labels
      if (options.showLabels) {
        final labelText = data.category;
        final textStyle = data.textStyle ?? options.defaultTextStyle;
        final textPainter = TextPainter(
          text: TextSpan(text: labelText, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelRadius = radius * 0.6;
        final x = center.dx + labelRadius * cos(midAngle);
        final y =
            center.dy + (labelRadius * options.ellipseRatio) * sin(midAngle);
        final offset = Offset(
          x - textPainter.width / 2,
          y - textPainter.height / 2,
        );

        textPainter.paint(canvas, offset);
      }

      currentAngle += sweepAngle;
    }
  }

  void _drawSplitDepthPath(
      Path path,
      Rect topArcRect,
      Rect bottomArcRect,
      double startAngle,
      double endAngle,
      double splitAngle,
      Offset center,
      double radius,
      double depthOffset,
      double ellipseRatio,
      ) {
    final sweep1 = splitAngle - startAngle;
    final sweep2 = endAngle - splitAngle;



    if (splitAngle == pi) {

      // Handle leftmost slice (π)
      path.moveTo(
        center.dx + radius * cos(startAngle),
        center.dy + (radius * ellipseRatio) * sin(startAngle),
      );
      path.arcTo(topArcRect, startAngle, sweep1, false);
      final topSplitPoint = Offset(
        center.dx + radius * cos(splitAngle),
        center.dy + (radius * ellipseRatio) * sin(splitAngle),
      );

      final bottomSplitPoint = Offset(
        topSplitPoint.dx,
        topSplitPoint.dy + depthOffset,
      );
      path.lineTo(bottomSplitPoint.dx, bottomSplitPoint.dy);

      path.arcTo(bottomArcRect, splitAngle, -sweep1, false);
      path.lineTo(
        center.dx + radius * cos(startAngle),
        center.dy + (radius * ellipseRatio) * sin(startAngle) + depthOffset,
      );
      path.close();
    }
    else if (splitAngle == 0) {
      // Handle rightmost slice (0)
      // Similar logic to the leftmost slice, but adjusted for the rightmost edge

      path.arcTo(topArcRect, startAngle, sweep1, false);
      final topSplitPoint = Offset(
        center.dx + radius * cos(splitAngle),
        center.dy + (radius * ellipseRatio) * sin(splitAngle),
      );

      final bottomSplitPoint = Offset(
        topSplitPoint.dx,
        topSplitPoint.dy + depthOffset,
      );
      path.lineTo(bottomSplitPoint.dx, bottomSplitPoint.dy);

      path.arcTo(bottomArcRect, splitAngle, sweep2, false);
      final topEndPoint = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + (radius * ellipseRatio) * sin(endAngle),
      );
      path.lineTo(topEndPoint.dx, topEndPoint.dy);
      path.close();
    } else {

    }
  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color darkenColor(Color originalColor, double factor) {
    return originalColor.withValues(
      red: (originalColor.r * factor).clamp(0, 255),
      green: (originalColor.g * factor).clamp(0, 255),
      blue: (originalColor.b * factor).clamp(0, 255),
      alpha: originalColor.a.toDouble(),  // Keep the same alpha value
    );
  }
}
