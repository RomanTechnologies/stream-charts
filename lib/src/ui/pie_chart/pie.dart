import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/chart/data.dart';
import 'package:stream_charts/src/ui/chart/painter.dart';
import 'package:stream_charts/src/ui/chart/tween.dart';
import 'package:stream_charts/src/ui/chart/type.dart';
import 'package:stream_charts/src/utils.dart';

// Class for handling the controller
class Pie extends ChartType<PieData> {
  Pie({PieChartController controller}) : super(controller: controller);

  static Pie lerp(Pie begin, Pie end, double t) {
    PieChartController b = begin.controller; // Cast to correct controller
    PieChartController e = end.controller; // Cast to correct controller

    return Pie(
      controller: PieChartController(
        startOffset: lerpDouble(b.startOffset, e.startOffset, t),
        segmentPadding: lerpDouble(b.segmentPadding, e.segmentPadding, t),
        centerRadius: lerpDouble(b.centerRadius, e.centerRadius, t),
        segmentWidth: lerpDouble(b.segmentWidth, e.segmentWidth, t),
        selectedWidth: lerpDouble(b.selectedWidth, e.selectedWidth, t),
        segments: PieData.lerpAll(b.segments, e.segments, t),
        rounded: e.rounded,
        threeD: e.threeD,
        selected: e.selected,
      ),
    );
  }
}

// Model for each segment of a pie chart
class PieData extends ChartData {
  PieData({
    this.value,
    this.color,
    this.showLabel = false,
    this.label,
  });

  final double value;
  final Color color;
  final bool showLabel;
  final String label;

  // Create a random model
  factory PieData.random(double radius, int maxValue) {
    Random random = Random();
    return PieData(
      value: random.nextInt(maxValue).toDouble(),
      color: Color.fromRGBO(
        random.nextInt(255),
        random.nextInt(255),
        random.nextInt(255),
        1,
      ),
      showLabel: true,
      label: "# ${random.nextInt(100)}",
    );
  }

  // Create a valid model with zero values
  factory PieData.zero({Color color = Colors.white}) {
    return PieData(
      value: 0.0,
      color: color,
      showLabel: false,
      label: '',
    );
  }

  // Create a random list of models
  static List<PieData> randomSet({int minLength, int maxLength, int maxRadius, int maxValue, bool fixedRadius}) {
    Random random = Random();
    List<PieData> data = [];
    int dataLength = max(minLength, random.nextInt(maxLength));
    for (int i = 0; i < dataLength; i++) {
      data.add(
        PieData.random(
          fixedRadius ? maxRadius.toDouble() : random.nextInt(maxRadius).toDouble(),
          maxValue,
        ),
      );
    }
    return data;
  }

  // User to copy the current model with new parameters
  PieData copyWith({
    double radius,
    double value,
    Color color,
    bool showLabel,
    String label,
  }) {
    return PieData(
      value: value ?? this.value,
      color: color ?? this.color,
      showLabel: showLabel ?? this.showLabel,
      label: label ?? this.label,
    );
  }

  // Used to tween between two models
  static PieData lerp(PieData b, PieData e, double t) {
    return PieData(
      value: lerpDouble(b.value, e.value, t),
      color: Color.fromRGBO(
        lerpDouble(b.color.red, e.color.red, t).toInt(),
        lerpDouble(b.color.green, e.color.green, t).toInt(),
        lerpDouble(b.color.blue, e.color.blue, t).toInt(),
        lerpDouble(b.color.opacity, e.color.opacity, t),
      ),
      showLabel: e.showLabel,
      label: e.label,
    );
  }

  // Tween a list of this model
  static List<PieData> lerpAll(List<PieData> b, List<PieData> e, double t) {
    List<PieData> segments = [];
    int length = e.length;
    if (b.length > e.length) {
      length = b.length;
    }

    for (int i = 0; i < length; i++) {
      if (i > b.length - 1) {
        PieData begin = PieData.zero();
        segments.add(PieData.lerp(begin, e[i], t));
      } else if (i > e.length - 1) {
        PieData end = PieData.zero(color: Colors.white.withOpacity(0));
        segments.add(PieData.lerp(b[i], end, t));
      } else {
        segments.add(PieData.lerp(b[i], e[i], t));
      }
    }

    return segments;
  }
}

// Controller class for handling and rebuilding of chart
class PieChartController extends ChartController<PieData> {
  PieChartController({
    this.segments,
    this.segmentPadding,
    this.centerRadius,
    this.segmentWidth,
    this.selectedWidth,
    this.startOffset,
    this.rounded,
    this.threeD,
    this.selected,
  });

  // The segments of the pie chart to draw
  List<PieData> segments;

  // Size of the padding between each segment
  double segmentPadding;

  // Radius of the center circle
  double centerRadius;

  // Width of each segment
  double segmentWidth;

  // Width of each selected segment
  double selectedWidth;

  // Offset starting position for drawing segments (in radians)
  double startOffset;

  // Option to dictate segment shape
  bool rounded;

  // Option to switch between 2 and 3d
  bool threeD;

  // Map the index of the selected items
  Map<int, bool> selected;

  @override
  PieChartController copyWith({
    List<PieData> segments,
    double segmentPadding,
    double centerRadius,
    double segmentWidth,
    double selectedWidth,
    double startOffset,
    bool rounded,
    bool threeD,
    Map<int, bool> selected,
  }) {
    return PieChartController(
      segments: segments ?? this.segments,
      segmentPadding: segmentPadding ?? this.segmentPadding,
      centerRadius: centerRadius ?? this.centerRadius,
      segmentWidth: segmentWidth ?? this.segmentWidth,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      startOffset: startOffset ?? this.startOffset,
      rounded: rounded ?? this.rounded,
      threeD: threeD ?? this.threeD,
      selected: selected ?? {} ?? this.selected,
    );
  }

  factory PieChartController.empty() {
    return PieChartController(
      segments: [],
      segmentPadding: 0,
      centerRadius: 0,
      segmentWidth: 0,
      selectedWidth: 0,
      startOffset: 0,
      rounded: false,
      threeD: false,
      selected: {},
    );
  }
}

class PieTween extends ChartTween<Pie> {
  PieTween(Pie begin, Pie end) : super(begin: begin, end: end);

  @override
  Pie lerp(double t) => Pie.lerp(begin, end, t);
}

class PieChartPainter extends ChartPainter {
  PieChartPainter({
    Animation<Pie> animation,
    Function onSelect,
  })  : animation = animation,
        super(animation: animation, onSelect: onSelect) {
    sectionPaint = Paint()..style = PaintingStyle.stroke;
    sectionPaint..strokeWidth = 5;

    sectionsSpaceClearPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x000000000)
      ..blendMode = BlendMode.srcOut;

    centerSpacePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
  }

  Paint sectionPaint, sectionsSpaceClearPaint, centerSpacePaint;

  @override
  Animation<Pie> animation;
  PieChartController controller;

  @override
  void paint(Canvas canvas, Size size) {
    controller = animation.value.controller;

    if (controller == null) {
      return;
    }

    if (size.width == 0 || size.height == 0) {
      return;
    }

    var center = Offset(
      size.width / 2,
      size.height / 2,
    );

    paths = [];
    super.paths = [];

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    _drawSegments(
      canvas,
      size: size,
      center: center,
      centerRadius: controller.centerRadius,
      segmentWidth: controller.segmentWidth,
      rounded: controller.rounded,
    );

    if (!controller.rounded) {
      _drawPadding(canvas, size, center);
    }

    _drawCenter(canvas, size);

    canvas.restore();
  }

  void _drawCenter(Canvas canvas, Size viewSize) {
    double centerX = viewSize.width / 2;
    double centerY = viewSize.height / 2;

    canvas.drawCircle(
      Offset(centerX, centerY),
      controller.centerRadius,
      sectionsSpaceClearPaint,
    );
  }

  /// firstly the sections draw close to eachOther without any space,
  /// then here we clear a line with given [PieChartData.width]
  void _drawPadding(Canvas canvas, Size size, Offset center) {
    double total = 0;
    List<double> values = controller.segments.map((segment) => segment.value).toList();
    for (double d in values) {
      total += d;
    }

    List<double> radiansAngle = List<double>();
    for (int i = 0; i < controller.segments.length; i++) {
      double radian = controller.segments[i].value * 2 * pi / total;
      radiansAngle.add(radian);
    }

    var currentAngle = controller.startOffset;

    sectionsSpaceClearPaint.strokeWidth = controller.segmentPadding;
    for (int i = 0; i < radiansAngle.length; i++) {
      var rd = radiansAngle[i];

      canvas.drawLine(
        center ?? Offset.zero,
        _getSegmentEnd(
              center,
              controller.centerRadius + controller.selectedWidth,
              currentAngle + rd,
            ) ??
            Offset.zero,
        sectionsSpaceClearPaint,
      );

      currentAngle += rd;
    }
  }

  void _drawTexts(Canvas canvas, Size viewSize, double total) {
    Offset center = Offset(viewSize.width / 2, viewSize.height / 2);

    double tempAngle = controller.startOffset;
    controller.segments.forEach((segment) {
      double startAngle = tempAngle;
      double sweepAngle = 360 * (segment.value / total);
      double sectionCenterAngle = startAngle + (sweepAngle / 2);
      Offset sectionCenterOffset = center +
          Offset(
            math.cos(radians(sectionCenterAngle)) * (controller.centerRadius + (controller.segmentWidth)),
            math.sin(radians(sectionCenterAngle)) * (controller.centerRadius + (controller.segmentWidth)),
          );

      if (segment.showLabel) {
        TextSpan span = TextSpan(text: segment.label);
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, sectionCenterOffset - Offset(tp.width / 2, tp.height / 2));
      }

      tempAngle += sweepAngle;
    });
  }

  // NEW VERSION
  void _drawSegment(Canvas canvas, Paint paint, {Offset center, double radius, startRadian = 0.0, sweepRadian = 0.0}) {
    Path path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius + controller.segmentWidth),
      startRadian,
      sweepRadian,
    );
    path.lineTo(center.dx, center.dy);
    path.fillType = PathFillType.nonZero;
    paths.add(path);

    // Add to make look bevelled
    if (controller.threeD) {
      paint.shader = RadialGradient(
        radius: 1,
        colors: [
          paint.color,
          Colors.black,
        ],
        stops: [
          .5,
          1.5,
        ],
        focalRadius: 1,
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: controller.centerRadius + controller.segmentWidth / 2),
      startRadian,
      sweepRadian,
      false,
      paint,
    );
  }

  Offset _getSegmentEnd(Offset center, double r, double radian) {
    return Offset(
      center.dx + r * cos(radian),
      center.dy + r * sin(radian),
    );
  }

  void _drawRoundedEnds(Canvas canvas, Paint paint,
      {Offset center, double radius, startRadian = 0.0, sweepRadian = pi, roundedStart = false, roundedEnd = false}) {
    // Add to make look bevelled
    if (controller.threeD) {
      paint.shader = RadialGradient(
        radius: 1,
        colors: [
          paint.color,
          Colors.black,
        ],
        stops: [
          .5,
          1.5,
        ],
        focalRadius: 1,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    if (roundedStart) {
      var startCenter = _getSegmentEnd(
        Offset(center.dx, center.dy),
        radius + controller.segmentWidth / 2,
        startRadian,
      );
      paint.style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCenter(
          center: startCenter,
          height: paint.strokeWidth,
          width: paint.strokeWidth,
        ),
        startRadian,
        -math.pi,
        false,
        paint,
      );
    }
    if (roundedEnd) {
      var endCenter = _getSegmentEnd(
        Offset(center.dx, center.dy),
        radius + controller.segmentWidth / 2,
        startRadian + sweepRadian,
      );
      paint.style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCenter(
          center: endCenter,
          height: paint.strokeWidth,
          width: paint.strokeWidth,
        ),
        startRadian + sweepRadian,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawSegments(Canvas canvas,
      {Offset center, Size size, double centerRadius, double segmentWidth, bool rounded = false, hasCurrent = false, int curIndex = 0}) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = segmentWidth
      ..isAntiAlias = true;

    double total = 0;
    List<double> values = controller.segments.map((segment) => segment.value).toList();
    for (double d in values) {
      total += d;
    }

    List<double> radiansAngle = List<double>();
    for (int i = 0; i < controller.segments.length; i++) {
      double radian = controller.segments[i].value * 2 * pi / total;
      radiansAngle.add(radian);
    }

    var currentAngle = controller.startOffset;
    paint.style = PaintingStyle.stroke;

    var curStartAngle = 0.0;

    for (int i = 0; i < radiansAngle.length; i++) {
      var rd = radiansAngle[i];
//      if (hasCurrent && curIndex == i) {
//        curStartAngle = currentAngle;
//        currentAngle += rd;
//        continue;
//      }

      paint.color = controller.segments[i].color;

      paint.strokeWidth = segmentWidth;
      if (controller.selected.containsKey(i)) {
        if (controller.selected[i] == true) {
          paint.strokeWidth = controller.selectedWidth;
        }
      }

      paint.style = PaintingStyle.stroke;

      _drawSegment(
        canvas,
        paint,
        center: center,
        radius: centerRadius,
        startRadian: currentAngle,
        sweepRadian: rd,
      );
      currentAngle += rd;
    }
    if (rounded) {
      currentAngle = controller.startOffset;
//      paint.strokeWidth = segmentWidth;
      for (int i = 0; i < radiansAngle.length; i++) {
        var rd = radiansAngle[i];
        if (hasCurrent && curIndex == i) {
          currentAngle += rd;
          continue;
        }
        paint.color = controller.segments[i].color;
//        paint.strokeWidth = segmentWidth;

        paint.strokeWidth = segmentWidth;
        if (controller.selected.containsKey(i)) {
          if (controller.selected[i] == true) {
            paint.strokeWidth = controller.selectedWidth;
          }
        }

        _drawRoundedEnds(
          canvas, paint,
          center: center,
          radius: centerRadius,
          startRadian: currentAngle,
          sweepRadian: rd,
          roundedStart: true,
//          roundedEnd: true,
        );
        currentAngle += rd;
      }
    }

//    if (hasCurrent) {
//      paint.color = controller.segments[curIndex].color;
////      paint.strokeWidth = segmentWidth;
//      paint.style = PaintingStyle.stroke;
//      _drawSegment(
//        canvas,
//        paint,
//        center: center,
//        radius: centerRadius,
//        startRadian: curStartAngle,
//        sweepRadian: radiansAngle[curIndex],
//      );
//    }
//    if (hasCurrent && rounded) {
//      var rd = radiansAngle[curIndex % radiansAngle.length];
//      paint.color = controller.segments[curIndex].color;
////      paint.strokeWidth = segmentWidth;
//      paint.style = PaintingStyle.fill;
//      _drawRoundedEnds(canvas, paint,
//          center: center,
//          radius: centerRadius,
//          startRadian: curStartAngle,
//          sweepRadian: rd,
//          roundedEnd: true,
//          roundedStart: true);
//    }
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
