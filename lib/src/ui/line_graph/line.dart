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

  /// [barPaint] is responsible to painting the bar line
  /// [barAreaPaint] is responsible to fill the below or above space of the bar line
  /// [barAreaLinesPaint] is responsible to draw vertical lines on above or below of the bar line
  /// [pointPaint] is responsible to draw dots on spot points
  /// [clearAroundBorderPaint] is responsible to clip the border
  /// [extraLinesPaint] is responsible to draw extr lines
  /// [touchLinePaint] is responsible to draw touch indicators(below line and spot)
  /// [bgTouchTooltipPaint] is responsible to draw box backgroundTooltip of touched point;
  Paint barPaint,
      barAreaPaint,
      barAreaLinesPaint,
      clearBarAreaPaint,
      pointPaint,
      clearAroundBorderPaint,
      extraLinesPaint,
      touchLinePaint;

  @override
  void paint(Canvas canvas, Size viewSize) {
    controller = animation.value.controller as LineGraphController;

    if (controller == null) {
      return;
    }

//    if (data.clipToBorder) {
//      /// save layer to clip it to border after lines drew
//      canvas.saveLayer(Rect.fromLTWH(0, -40, viewSize.width + 40, viewSize.height + 40), Paint());
//    }

    /// it holds list of nearest touched spots of each line
    /// and we use it to draw touch stuff on them
//    final List<LineTouchedSpot> touchedSpots = [];

    /// draw each line independently on the chart
    for (int i = 0; i < controller.data.length; i++) {
      final lineData = controller.data[i];

      _makeLine(canvas, viewSize, lineData);
      _drawPoints(canvas, viewSize, lineData);

      // find the nearest spot on touch area in this bar line
//      final LineTouchedSpot foundTouchedSpot = _getNearestTouchedSpot(canvas, viewSize, lineData, i);
//      if (foundTouchedSpot != null) {
//        touchedSpots.add(foundTouchedSpot);
//      }
    }

//    if (data.clipToBorder) {
//      removeOutsideBorder(canvas, viewSize);
//
//      /// restore layer to previous state (after clipping the chart)
//      canvas.restore();
//    }

    // Draw touch indicators (below spot line and spot dot)
//    drawTouchedSpotsIndicator(canvas, viewSize, touchedSpots);

//    drawTitles(canvas, viewSize);

//    drawExtraLines(canvas, viewSize);

    // Draw touch tooltip on most top spot
//    super.drawTouchTooltip(canvas, viewSize, data.lineTouchData.touchTooltipData, touchedSpots);

//    if (touchedResponseSink != null &&
//        touchInputNotifier != null &&
//        touchInputNotifier.value != null &&
//        !(touchInputNotifier.value.runtimeType is NonTouch)) {
//      touchedResponseSink.add(LineTouchResponse(touchedSpots, touchInputNotifier.value));
//    }
  }

  void _makeLine(Canvas canvas, Size viewSize, LineData lineData) {
    final linePath = _generateBarPath(viewSize, lineData);

//    final belowBarPath = _generateBelowBarPath(viewSize, lineConfig, barPath);
//    final completelyFillBelowBarPath = _generateBelowBarPath(viewSize, lineConfig, barPath, fillCompletely: true);
//
//    final aboveBarPath = _generateAboveBarPath(viewSize, lineConfig, barPath);
//    final completelyFillAboveBarPath = _generateAboveBarPath(viewSize, lineConfig, barPath, fillCompletely: true);

//    _drawBelowBar(canvas, viewSize, belowBarPath, completelyFillAboveBarPath, lineConfig);
//    _drawAboveBar(canvas, viewSize, aboveBarPath, completelyFillBelowBarPath, lineConfig);
    _drawLine(canvas, viewSize, linePath, lineData);
  }

  /// find the nearest spot base on the touched offset
//  LineTouchedSpot _getNearestTouchedSpot(Canvas canvas, Size viewSize, LineChartBarData barData, int barDataPosition) {
//    final Size chartViewSize = getChartUsableDrawSize(viewSize);
//
//    if (touchInputNotifier == null || touchInputNotifier.value == null) {
//      return null;
//    }
//
//    final touch = touchInputNotifier.value;
//
//    if (touch.getOffset() == null) {
//      return null;
//    }
//
//    final touchedPoint = touch.getOffset();
//
//    /// Find the nearest spot (on X axis)
//    for (FlSpot spot in barData.spots) {
//      if ((touchedPoint.dx - getPixelX(spot.x, chartViewSize)).abs() <= data.lineTouchData.touchSpotThreshold) {
//        final nearestSpot = spot;
//        final Offset nearestSpotPos = Offset(
//          getPixelX(nearestSpot.x, chartViewSize),
//          getPixelY(nearestSpot.y, chartViewSize),
//        );
//
//        return LineTouchedSpot(barData, barDataPosition, nearestSpot, nearestSpotPos);
//      }
//    }
//
//    return null;
//  }

  void _drawPoints(Canvas canvas, Size viewSize, LineData lineData) {
    if (lineData.points == null) {
      return;
    }
    lineData.points.forEach((point) {
//      if (lineData.dotData.checkToShowDot(spot)) {
      pointPaint.color = point.color;
      canvas.drawCircle(Offset(point.x, point.y), point.size, pointPaint);
//      }
    });
  }

  /// firstly we generate the bar line that we should draw,
  /// then we reuse it to fill below bar space.
  /// there is two type of barPath that generate here,
  /// first one is the sharp corners line on spot connections
  /// second one is curved corners line on spot connections,
  /// and we use isCurved to find out how we should generate it,
  Path _generateBarPath(Size viewSize, LineData lineData) {
    Path path = Path();
    int size = lineData.points.length;
    path.reset();

    var temp = const Offset(0.0, 0.0);

//    double x = getPixelX(lineConfig.points[0].x, viewSize);
//    double y = getPixelY(lineConfig.points[0].y, viewSize);
    path.moveTo(
      lineData.points[0].x,
      lineData.points[0].y,
    );
    for (int i = 1; i < size; i++) {
      /// CurrentSpot
      final current = Offset(
        lineData.points[i].x,
        lineData.points[i].y,
      );

      /// previous spot
      final previous = Offset(
        lineData.points[i - 1].x,
        lineData.points[i - 1].y,
      );

      /// next point
      final next = Offset(
        lineData.points[i + 1 < size ? i + 1 : i].x,
        lineData.points[i + 1 < size ? i + 1 : i].y,
      );

      final controlPoint1 = previous + temp;

      /// if the isCurved is false, we set 0 for smoothness,
      /// it means we should not have any smoothness then we face with
      /// the sharped corners line
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

//  /// it generates below area path using a copy of [barPath],
//  /// if cutOffY is provided by the [BarAreaData], it cut the area to the provided cutOffY value,
//  /// if [fillCompletely] is true, the cutOffY will be ignored,
//  /// and a completely filled path will return,
//  Path _generateBelowBarPath(Size viewSize, LineData lineData, Path barPath, {bool fillCompletely = false}) {
//    final belowBarPath = Path.from(barPath);
//
//    final chartViewSize = viewSize;
//
//    /// Line To Bottom Right
//    double x = lineData.points[lineData.points.length - 1].x;
//    double y;
//    if (!fillCompletely && lineData.belowBarData.applyCutOffY) {
//      y = lineData.belowBarData.cutOffY;
//    } else {
//      y = chartViewSize.height + getTopOffsetDrawSize();
//    }
//    belowBarPath.lineTo(x, y);
//
//    /// Line To Bottom Left
//    x = lineData.points[0].x;
//    if (!fillCompletely && lineData.belowBarData.applyCutOffY) {
//      y = lineData.belowBarData.cutOffY;
//    } else {
//      y = chartViewSize.height + getTopOffsetDrawSize();
//    }
//    belowBarPath.lineTo(x, y);
//
//    /// Line To Top Left
//    x = lineData.points[0].x;
//    y = lineData.points[0].y;
//    belowBarPath.lineTo(x, y);
//    belowBarPath.close();
//
//    return belowBarPath;
//  }
//
//  /// it generates above area path using a copy of [barPath],
//  /// if cutOffY is provided by the [BarAreaData], it cut the area to the provided cutOffY value,
//  /// if [fillCompletely] is true, the cutOffY will be ignored,
//  /// and a completely filled path will return,
//  Path _generateAboveBarPath(Size viewSize, LineData lineData, Path barPath, {bool fillCompletely = false}) {
//    final aboveBarPath = Path.from(barPath);
//
//    final chartViewSize = viewSize;
//
//    /// Line To Top Right
//    double x = lineData.points[lineData.points.length - 1].x;
//    double y;
//    if (!fillCompletely && lineData.aboveBarData.applyCutOffY) {
//      y = lineData.aboveBarData.cutOffY;
//    } else {
//      y = getTopOffsetDrawSize();
//    }
//    aboveBarPath.lineTo(x, y);
//
//    /// Line To Top Left
//    x = lineData.points[0].x;
//    if (!fillCompletely && lineData.aboveBarData.applyCutOffY) {
//      y = lineData.aboveBarData.cutOffY;
//    } else {
//      y = getTopOffsetDrawSize();
//    }
//    aboveBarPath.lineTo(x, y);
//
//    /// Line To Bottom Left
//    x = lineData.points[0].x;
//    y = lineData.points[0].y;
//    aboveBarPath.lineTo(x, y);
//    aboveBarPath.close();
//
//    return aboveBarPath;
//  }
//
//  /// firstly we draw [belowBarPath], then if cutOffY value is provided in [BarAreaData],
//  /// [belowBarPath] maybe draw over the main bar line,
//  /// then to fix the problem we use [filledAboveBarPath] to clear the above section from this draw.
//  void _drawBelowBar(Canvas canvas, Size viewSize, Path belowBarPath, Path filledAboveBarPath, LineData lineData) {
//    if (!lineData.belowBarData.show) {
//      return;
//    }
//
//    final chartViewSize = viewSize;
//
//    /// here we update the [belowBarPaint] to draw the solid color
//    /// or the gradient based on the [BarAreaData] class.
//    if (lineData.belowBarData.colors.length == 1) {
//      barAreaPaint.color = lineData.belowBarData.colors[0];
//      barAreaPaint.shader = null;
//    } else {
//      List<double> stops = [];
//      if (lineData.belowBarData.gradientColorStops == null ||
//          lineData.belowBarData.gradientColorStops.length != lineData.belowBarData.colors.length) {
//        /// provided gradientColorStops is invalid and we calculate it here
//        lineData.colors.asMap().forEach((index, color) {
//          final percent = 1.0 / lineData.colors.length;
//          stops.add(percent * (index + 1));
//        });
//      } else {
//        stops = lineData.belowBarData.gradientColorStops;
//      }
//
//      final from = lineData.belowBarData.gradientFrom;
//      final to = lineData.belowBarData.gradientTo;
//      barAreaPaint.shader = ui.Gradient.linear(
//        Offset(
//          getLeftOffsetDrawSize() + (chartViewSize.width * from.dx),
//          getTopOffsetDrawSize() + (chartViewSize.height * from.dy),
//        ),
//        Offset(
//          getLeftOffsetDrawSize() + (chartViewSize.width * to.dx),
//          getTopOffsetDrawSize() + (chartViewSize.height * to.dy),
//        ),
//        lineData.belowBarData.colors,
//        stops,
//      );
//    }
//
//    if (lineData.belowBarData.applyCutOffY) {
//      canvas.saveLayer(Rect.fromLTWH(0, 0, viewSize.width, viewSize.height), Paint());
//    }
//
//    canvas.drawPath(belowBarPath, barAreaPaint);
//
//    // clear the above area that get out of the bar line
//    if (lineData.belowBarData.applyCutOffY) {
//      canvas.drawPath(filledAboveBarPath, clearBarAreaPaint);
//      canvas.restore();
//    }
//
//    /// draw below spots line
//    if (lineData.belowBarData.spotsLine != null && lineData.belowBarData.spotsLine.show) {
//      for (PointData point in lineData.points) {
//        if (lineData.belowBarData.spotsLine.checkToShowSpotLine(point)) {
//          final Offset from = Offset(
//            point.x,
//            point.y,
//          );
//
//          final double bottomPadding = getExtraNeededVerticalSpace() - getTopOffsetDrawSize();
//          final Offset to = Offset(
//            point.x,
//            viewSize.height - bottomPadding,
//          );
//
//          barAreaLinesPaint.color = lineData.belowBarData.spotsLine.flLineStyle.color;
//          barAreaLinesPaint.strokeWidth = lineData.belowBarData.spotsLine.flLineStyle.strokeWidth;
//
//          canvas.drawLine(from, to, barAreaLinesPaint);
//        }
//      }
//    }
//  }
//
//  /// firstly we draw [aboveBarPath], then if cutOffY value is provided in [BarAreaData],
//  /// [aboveBarPath] maybe draw over the main bar line,
//  /// then to fix the problem we use [filledBelowBarPath] to clear the above section from this draw.
//  void _drawAboveBar(Canvas canvas, Size viewSize, Path aboveBarPath, Path filledBelowBarPath, LineData lineData) {
//    if (!lineData.aboveBarData.show) {
//      return;
//    }
//    final chartViewSize = viewSize;
//
//    /// here we update the [aboveBarPaint] to draw the solid color
//    /// or the gradient based on the [BarAreaData] class.
//    if (lineData.aboveBarData.colors.length == 1) {
//      barAreaPaint.color = lineData.aboveBarData.colors[0];
//      barAreaPaint.shader = null;
//    } else {
//      List<double> stops = [];
//      if (lineData.aboveBarData.gradientColorStops == null ||
//          lineData.aboveBarData.gradientColorStops.length != lineData.aboveBarData.colors.length) {
//        /// provided gradientColorStops is invalid and we calculate it here
//        lineData.colors.asMap().forEach((index, color) {
//          final percent = 1.0 / lineData.colors.length;
//          stops.add(percent * (index + 1));
//        });
//      } else {
//        stops = lineData.aboveBarData.gradientColorStops;
//      }
//
//      final from = lineData.aboveBarData.gradientFrom;
//      final to = lineData.aboveBarData.gradientTo;
//      barAreaPaint.shader = ui.Gradient.linear(
//        Offset(
//          getLeftOffsetDrawSize() + (chartViewSize.width * from.dx),
//          getTopOffsetDrawSize() + (chartViewSize.height * from.dy),
//        ),
//        Offset(
//          getLeftOffsetDrawSize() + (chartViewSize.width * to.dx),
//          getTopOffsetDrawSize() + (chartViewSize.height * to.dy),
//        ),
//        lineData.aboveBarData.colors,
//        stops,
//      );
//    }
//
//    canvas.saveLayer(Rect.fromLTWH(0, 0, viewSize.width, viewSize.height), Paint());
//    canvas.drawPath(aboveBarPath, barAreaPaint);
//
//    // clear the above area that get out of the bar line
//    canvas.drawPath(filledBelowBarPath, clearBarAreaPaint);
//    canvas.restore();
//
//    /// draw above spots line
//    if (lineData.aboveBarData.spotsLine != null && lineData.aboveBarData.spotsLine.show) {
//      for (PointData point in lineData.points) {
//        if (lineData.aboveBarData.spotsLine.checkToShowSpotLine(point)) {
//          final Offset from = Offset(
//            point.x,
//            point.y,
//          );
//
//          final Offset to = Offset(
//            point.x,
//            getTopOffsetDrawSize(),
//          );
//
//          barAreaLinesPaint.color = lineData.aboveBarData.spotsLine.flLineStyle.color;
//          barAreaLinesPaint.strokeWidth = lineData.aboveBarData.spotsLine.flLineStyle.strokeWidth;
//
//          canvas.drawLine(from, to, barAreaLinesPaint);
//        }
//      }
//    }
//  }

  /// draw the main bar line by the [barPath]
  void _drawLine(Canvas canvas, Size viewSize, Path barPath, LineData lineData) {
//    if (!lineData.show) {
//      return;
//    }

    barPaint.strokeCap = lineData.roundedEnds ? StrokeCap.round : StrokeCap.butt;

    /// here we update the [barPaint] to draw the solid color or
    /// the gradient color,
    /// if we have one color, solid color will apply,
    /// but if we have more than one color, gradient will apply.
//    if (lineData.colors.length == 1) {
//      barPaint.color = lineData.colors[0];
    barPaint.color = lineData.color;
    barPaint.shader = null;
//    } else {
//      List<double> stops = [];
//      if (lineData.colorStops == null || lineData.colorStops.length != lineData.colors.length) {
//        /// provided colorStops is invalid and we calculate it here
//        lineData.colors.asMap().forEach((index, color) {
//          double ss = 1.0 / lineData.colors.length;
//          stops.add(ss * (index + 1));
//        });
//      } else {
//        stops = lineData.colorStops;
//      }
//
//      barPaint.shader = ui.Gradient.linear(
//        Offset(
//          getLeftOffsetDrawSize(),
//          getTopOffsetDrawSize() + (viewSize.height / 2),
//        ),
//        Offset(
//          getLeftOffsetDrawSize() + viewSize.width,
//          getTopOffsetDrawSize() + (viewSize.height / 2),
//        ),
//        lineData.colors,
//        stops,
//      );
//    }

//    barPaint.strokeWidth = lineData.barWidth;
    barPaint.strokeWidth = 10.0;
    canvas.drawPath(barPath, barPaint);
  }

//  /// clip the border (remove outside the border)
//  void removeOutsideBorder(Canvas canvas, Size viewSize) {
//    if (!data.clipToBorder) {
//      return;
//    }
//
//    clearAroundBorderPaint.strokeWidth = barPaint.strokeWidth / 2;
//    double halfStrokeWidth = clearAroundBorderPaint.strokeWidth / 2;
//    Rect rect = Rect.fromLTRB(
//      getLeftOffsetDrawSize() - halfStrokeWidth,
//      getTopOffsetDrawSize() - halfStrokeWidth,
//      viewSize.width - (getExtraNeededHorizontalSpace() - getLeftOffsetDrawSize()) + halfStrokeWidth,
//      viewSize.height - (getExtraNeededVerticalSpace() - getTopOffsetDrawSize()) + halfStrokeWidth,
//    );
//    canvas.drawRect(rect, clearAroundBorderPaint);
//  }

//  void drawTouchedSpotsIndicator(Canvas canvas, Size viewSize, List<LineTouchedSpot> lineTouchedSpots) {
//    if (!shouldDrawTouch()) {
//      return;
//    }
//
//    if (lineTouchedSpots == null || lineTouchedSpots.isEmpty) {
//      return;
//    }
//
//    final Size chartViewSize = getChartUsableDrawSize(viewSize);
//
//    /// sort the touched spots top to down, base on their y value
//    lineTouchedSpots.sort((a, b) => a.offset.dy.compareTo(b.offset.dy));
//
//    final List<TouchedSpotIndicatorData> indicatorsData = data.lineTouchData.getTouchedSpotIndicator(lineTouchedSpots);
//
//    if (indicatorsData.length != lineTouchedSpots.length) {
//      throw Exception('indicatorsData and touchedSpotOffsets size should be same');
//    }
//
//    for (int i = 0; i < lineTouchedSpots.length; i++) {
//      final TouchedSpotIndicatorData indicatorData = indicatorsData[i];
//      final LineTouchedSpot touchedSpot = lineTouchedSpots[i];
//
//      if (indicatorData == null) {
//        continue;
//      }
//
//      /// Draw the indicator line
//      final from = Offset(touchedSpot.offset.dx, getTopOffsetDrawSize() + chartViewSize.height);
//      final to = touchedSpot.offset;
//
//      touchLinePaint.color = indicatorData.indicatorBelowLine.color;
//      touchLinePaint.strokeWidth = indicatorData.indicatorBelowLine.strokeWidth;
//      canvas.drawLine(from, to, touchLinePaint);
//
//      /// Draw the indicator dot
//      final double selectedSpotDotSize = indicatorData.touchedSpotDotData.dotSize;
//      dotPaint.color = indicatorData.touchedSpotDotData.dotColor;
//      canvas.drawCircle(to, selectedSpotDotSize, dotPaint);
//    }
//  }

//  void drawTitles(Canvas canvas, Size viewSize) {
//    if (!data.titlesData.show) {
//      return;
//    }
//    viewSize = getChartUsableDrawSize(viewSize);
//
//    // Left Titles
//    final leftTitles = data.titlesData.leftTitles;
//    if (leftTitles.showTitles) {
//      double verticalSeek = data.minY;
//      while (verticalSeek <= data.maxY) {
//        double x = 0 + getLeftOffsetDrawSize();
//        double y = getPixelY(verticalSeek, viewSize);
//
//        final String text = leftTitles.getTitles(verticalSeek);
//
//        final TextSpan span = TextSpan(style: leftTitles.textStyle, text: text);
//        final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//        tp.layout(maxWidth: getExtraNeededHorizontalSpace());
//        x -= tp.width + leftTitles.margin;
//        y -= tp.height / 2;
//        tp.paint(canvas, Offset(x, y));
//
//        verticalSeek += leftTitles.interval;
//      }
//    }
//
//    // Top titles
//    final topTitles = data.titlesData.topTitles;
//    if (topTitles.showTitles) {
//      double horizontalSeek = data.minX;
//      while (horizontalSeek <= data.maxX) {
//        double x = getPixelX(horizontalSeek, viewSize);
//        double y = getTopOffsetDrawSize();
//
//        String text = topTitles.getTitles(horizontalSeek);
//
//        TextSpan span = TextSpan(style: topTitles.textStyle, text: text);
//        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//        tp.layout();
//
//        x -= tp.width / 2;
//        y -= topTitles.margin + tp.height;
//
//        tp.paint(canvas, Offset(x, y));
//
//        horizontalSeek += topTitles.interval;
//      }
//    }
//
//    // Right Titles
//    final rightTitles = data.titlesData.rightTitles;
//    if (rightTitles.showTitles) {
//      double verticalSeek = data.minY;
//      while (verticalSeek <= data.maxY) {
//        double x = viewSize.width + getLeftOffsetDrawSize();
//        double y = getPixelY(verticalSeek, viewSize);
//
//        final String text = rightTitles.getTitles(verticalSeek);
//
//        final TextSpan span = TextSpan(style: rightTitles.textStyle, text: text);
//        final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//        tp.layout(maxWidth: getExtraNeededHorizontalSpace());
//        x += rightTitles.margin;
//        y -= tp.height / 2;
//        tp.paint(canvas, Offset(x, y));
//
//        verticalSeek += rightTitles.interval;
//      }
//    }
//
//    // Bottom titles
//    final bottomTitles = data.titlesData.bottomTitles;
//    if (bottomTitles.showTitles) {
//      double horizontalSeek = data.minX;
//      while (horizontalSeek <= data.maxX) {
//        double x = getPixelX(horizontalSeek, viewSize);
//        double y = viewSize.height + getTopOffsetDrawSize();
//
//        String text = bottomTitles.getTitles(horizontalSeek);
//
//        TextSpan span = TextSpan(style: bottomTitles.textStyle, text: text);
//        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
//        tp.layout();
//
//        x -= tp.width / 2;
//        y += bottomTitles.margin;
//
//        tp.paint(canvas, Offset(x, y));
//
//        horizontalSeek += bottomTitles.interval;
//      }
//    }
//  }

//  void drawExtraLines(Canvas canvas, Size viewSize) {
//    if (data.extraLinesData == null) {
//      return;
//    }
//
//    final Size chartUsableSize = viewSize;
//
//    if (data.extraLinesData.showHorizontalLines) {
//      for (HorizontalLine line in data.extraLinesData.horizontalLines) {
//        final double topChartPadding = getTopOffsetDrawSize();
//        final Offset from = Offset(line.x, topChartPadding);
//
//        final double bottomChartPadding = getExtraNeededVerticalSpace() - getTopOffsetDrawSize();
//        final Offset to = Offset(line.x, viewSize.height - bottomChartPadding);
//
//        extraLinesPaint.color = line.color;
//        extraLinesPaint.strokeWidth = line.strokeWidth;
//
//        canvas.drawLine(from, to, extraLinesPaint);
//      }
//    }
//
//    if (data.extraLinesData.showVerticalLines) {
//      for (VerticalLine line in data.extraLinesData.verticalLines) {
//        final double leftChartPadding = getLeftOffsetDrawSize();
//        final Offset from = Offset(leftChartPadding, line.y);
//
//        final double rightChartPadding = getExtraNeededHorizontalSpace() - getLeftOffsetDrawSize();
//        final Offset to = Offset(viewSize.width - rightChartPadding, line.y);
//
//        extraLinesPaint.color = line.color;
//        extraLinesPaint.strokeWidth = line.strokeWidth;
//
//        canvas.drawLine(from, to, extraLinesPaint);
//      }
//    }
//  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
