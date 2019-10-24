import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/chart/data.dart';
import 'package:stream_charts/src/ui/chart/painter.dart';
import 'package:stream_charts/src/ui/chart/tween.dart';
import 'package:stream_charts/src/ui/chart/type.dart';

class Line extends ChartType<LineData> {
  Line({LineGraphController controller}) : super(controller: controller);

  static Line lerp(Line begin, Line end, double t) {
    LineGraphController b = begin.controller;
    LineGraphController e = end.controller;

    return Line(
      controller: LineGraphController(
        lines: LineData.lerpAll(b.lines, e.lines, t),
      ),
    );
  }
}

class LineGraphController extends ChartController<LineData> {
  LineGraphController({
    List<LineData> lines,
  }) : super(data: lines) {
    this.lines = lines;
  }

  List<LineData> lines;

  @override
  LineGraphController copyWith({
    List<LineData> lines,
  }) {
    return LineGraphController(
      lines: lines ?? super.data,
    );
  }

  factory LineGraphController.empty() {
    return LineGraphController(
      lines: [],
    );
  }
}

class LineData extends ChartData {
  LineData({
    this.points,
    this.shouldCurve,
    this.smoothness,
    this.overflow,
    this.roundedEnds,
    this.color,
  });

  final List<PointData> points;
  final bool shouldCurve;
  final double smoothness;
  final bool overflow;
  final bool roundedEnds;
  final Color color;

  LineData copyWith({
    List<PointData> points,
    bool shouldCurve,
    double smoothness,
    bool overflow,
    bool roundedEnds,
    Color color,
  }) {
    return LineData(
      points: points ?? this.points,
      shouldCurve: shouldCurve ?? this.shouldCurve,
      smoothness: smoothness ?? this.smoothness,
      overflow: overflow ?? this.overflow,
      roundedEnds: roundedEnds ?? this.roundedEnds,
      color: color ?? this.color,
    );
  }

  static LineData lerp(LineData b, LineData e, double t) {
    return LineData(
      points: PointData.lerpAll(b.points, e.points, t),
      shouldCurve: e.shouldCurve,
      smoothness: lerpDouble(b.smoothness, e.smoothness, t),
      overflow: e.overflow,
      roundedEnds: e.roundedEnds,
      color: Color.fromRGBO(
        lerpDouble(b.color.red, e.color.red, t).toInt(),
        lerpDouble(b.color.green, e.color.green, t).toInt(),
        lerpDouble(b.color.blue, e.color.blue, t).toInt(),
        lerpDouble(b.color.opacity, e.color.opacity, t),
      ),
    );
  }

  static List<LineData> lerpAll(List<LineData> b, List<LineData> e, double t) {
    List<LineData> lines = [];
    int length = e.length;
    if (b.length < e.length) {
      length = b.length;
    }

    for (int i = 0; i < length; i++) {
      lines.add(LineData.lerp(b[i], e[i], t));
    }
    return lines;
  }
}

class PointData {
  PointData({this.x, this.y, this.color, this.size});

  final double x;
  final double y;
  final Color color;
  final double size;

  PointData copyWith({
    double x,
    double y,
    Color color,
    double size,
  }) {
    return PointData(
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  static PointData lerp(PointData b, PointData e, double t) {
    return PointData(
      x: lerpDouble(b.x, e.x, t),
      y: lerpDouble(b.y, e.y, t),
      size: lerpDouble(b.size, e.size, t),
      color: Color.fromRGBO(
        lerpDouble(b.color.red, e.color.red, t).toInt(),
        lerpDouble(b.color.green, e.color.green, t).toInt(),
        lerpDouble(b.color.blue, e.color.blue, t).toInt(),
        lerpDouble(b.color.opacity, e.color.opacity, t),
      ),
    );
  }

  static List<PointData> lerpAll(List<PointData> b, List<PointData> end, double t) {
    List<PointData> points = [];
    int length = end.length;
    if (b.length < end.length) {
      length = b.length;
    }

    for (int i = 0; i < length; i++) {
      points.add(PointData.lerp(b[i], end[i], t));
    }
    return points;
  }
}

class LineTween extends ChartTween<Line> {
  LineTween(Line begin, Line end) : super(begin: begin, end: end);

  @override
  Line lerp(double t) => Line.lerp(begin, end, t);
}

class LineGraphPainter extends ChartPainter {
  static const spaceWidth = 25.0;

  LineGraphPainter({
    Animation<Line> animation,
    this.onSelect,
  })  : animation = animation,
        super(animation: animation) {
    barPaint = Paint()..style = PaintingStyle.stroke;

    barAreaPaint = Paint()..style = PaintingStyle.fill;

    barAreaLinesPaint = Paint()..style = PaintingStyle.stroke;

    clearBarAreaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x000000000)
      ..blendMode = BlendMode.dstIn;

    pointPaint = Paint()..style = PaintingStyle.fill;

    clearAroundBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x000000000)
      ..blendMode = BlendMode.dstIn;

    extraLinesPaint = Paint()..style = PaintingStyle.stroke;

    touchLinePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;
  }

  LineGraphController controller;
  @override
  Animation<Line> animation;

  final Function onSelect;

  Paint barPaint, barAreaPaint, barAreaLinesPaint, clearBarAreaPaint, pointPaint, clearAroundBorderPaint, extraLinesPaint, touchLinePaint;

  @override
  void paint(Canvas canvas, Size viewSize) {
    controller = animation.value.controller as LineGraphController;

    if (controller == null) {
      return;
    }

    for (int i = 0; i < controller.data.length; i++) {
      final lineData = controller.data[i];

      _makeLine(canvas, viewSize, lineData);
      _drawPoints(canvas, viewSize, lineData);
    }
  }

  void _makeLine(Canvas canvas, Size viewSize, LineData lineData) {
    final linePath = _makeLinePath(viewSize, lineData);

    _drawLine(canvas, viewSize, linePath, lineData);
  }

  void _drawPoints(Canvas canvas, Size viewSize, LineData lineData) {
    if (lineData.points == null) {
      return;
    }
    lineData.points.forEach((point) {
      pointPaint.color = point.color;
      canvas.drawCircle(Offset(point.x, point.y), point.size, pointPaint);
    });
  }

  Path _makeLinePath(Size viewSize, LineData lineData) {
    Path path = Path();
    int size = lineData.points.length;
    path.reset();

    var temp = const Offset(0.0, 0.0);

    path.moveTo(
      lineData.points[0].x,
      lineData.points[0].y,
    );
    for (int i = 1; i < size; i++) {
      final current = Offset(
        lineData.points[i].x,
        lineData.points[i].y,
      );

      final previous = Offset(
        lineData.points[i - 1].x,
        lineData.points[i - 1].y,
      );

      final next = Offset(
        lineData.points[i + 1 < size ? i + 1 : i].x,
        lineData.points[i + 1 < size ? i + 1 : i].y,
      );

      final controlPoint1 = previous + temp;

      final smoothness = lineData.shouldCurve ? lineData.smoothness : 0.0;
      temp = ((next - previous) / 2) * smoothness;

      if (lineData.overflow) {
        if ((next - current).dy <= 10 || (current - previous).dy <= 10) {
          temp = Offset(temp.dx, 0);
        }

        if ((next - current).dx <= 10 || (current - previous).dx <= 10) {
          temp = Offset(0, temp.dy);
        }
      }

      final controlPoint2 = current - temp;

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  void _drawLine(Canvas canvas, Size viewSize, Path linePath, LineData lineData) {
    barPaint.strokeCap = lineData.roundedEnds ? StrokeCap.round : StrokeCap.butt;

    barPaint.color = lineData.color;
    barPaint.shader = null;
    barPaint.strokeWidth = 10.0;
    canvas.drawPath(linePath, barPaint);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
