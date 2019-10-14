import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/chart/data.dart';
import 'package:stream_charts/src/ui/chart/painter.dart';
import 'package:stream_charts/src/ui/chart/tween.dart';
import 'package:stream_charts/src/ui/chart/type.dart';

class Bar extends ChartType<BarData> {
  Bar({BarChartController controller}) : super(controller: controller);

  static Bar lerp(Bar begin, Bar end, double t) {
    BarChartController beginController = begin.controller;
    BarChartController endController = end.controller;

    return Bar(
      controller: BarChartController(
        bars: BarData.lerpAll(beginController.bars, endController.bars, t),
        spacing: lerpDouble(beginController.spacing, endController.spacing, t),
        showBarBg: endController.showBarBg,
      ),
    );
  }
}

class BarData extends ChartData {
  BarData({this.height, this.color, this.group});

  final String group;
  final double height;
  final Color color;

  BarData copyWith({
    String group,
    double height,
    Color color,
  }) {
    return BarData(
      group: group ?? this.group,
      height: height ?? this.height,
      color: color ?? this.color,
    );
  }

  static BarData lerp(BarData begin, BarData end, double t) {
    return BarData(
      group: end.group,
      height: lerpDouble(begin.height, end.height, t),
      color: Color.fromRGBO(
        lerpDouble(begin.color.red, end.color.red, t).toInt(),
        lerpDouble(begin.color.green, end.color.green, t).toInt(),
        lerpDouble(begin.color.blue, end.color.blue, t).toInt(),
        1,
      ),
    );
  }

  static List<BarData> lerpAll(List<BarData> begin, List<BarData> end, double t) {
    List<BarData> bars = [];
    int length = end.length;
    if (begin.length > end.length) {
      length = begin.length;
    }

    for (int i = 0; i < length; i++) {
      bars.add(BarData.lerp(begin[i], end[i], t));
    }
    return bars;
  }
}

class BarChartController extends ChartController<BarData> {
  BarChartController({
    List<BarData> bars,
    this.spacing,
    this.showBarBg,
  }) : super(data: bars) {
    this.bars = bars;
  }

  List<BarData> bars;
  final double spacing;
  final bool showBarBg;

  @override
  BarChartController copyWith({
    List<BarData> bars,
    double spacing,
    bool showBarBg,
  }) {
    return BarChartController(
      bars: bars ?? super.data,
      spacing: spacing ?? this.spacing,
      showBarBg: showBarBg ?? this.showBarBg,
    );
  }

  factory BarChartController.empty() {
    return BarChartController(
      spacing: 20,
      showBarBg: false,
      bars: [],
    );
  }
}

class BarTween extends ChartTween<Bar> {
  BarTween(Bar begin, Bar end) : super(begin: begin, end: end);

  @override
  Bar lerp(double t) => Bar.lerp(begin, end, t);
}

class BarChartPainter extends ChartPainter {
  BarChartPainter({
    Animation<Bar> animation,
    this.onSelect,
  })  : animation = animation,
        super(animation: animation);

  Animation<Bar> animation;
  BarChartController controller;
  final Function onSelect;

  @override
  void paint(Canvas canvas, Size size) {
    controller = animation.value.controller;

    if (controller == null) {
      return;
    }

    final paint = Paint()
      ..color = Colors.blue[400]
      ..style = PaintingStyle.fill;

    final sectionWidth = size.width / controller.data.length;

    Paint bgPaint = Paint();
    bgPaint.color = Colors.grey.withOpacity(.7);

    final double startOffset = controller.spacing / 4;

    for (int i = 0; i < controller.data.length; i++) {
//       Bg
      BarData bar = controller.data[i];

      if (controller.showBarBg) {
        _drawBarBg(
          canvas,
          bgPaint,
          Rect.fromLTWH(
            startOffset + (sectionWidth * i),
            0,
            sectionWidth - controller.spacing / 2,
            size.height,
          ),
        );
      }

      paint.color = bar.color;
      // Bar
      _drawBar(
        canvas,
        paint,
        Rect.fromLTWH(
          startOffset + (sectionWidth * i),
          size.height - bar.height,
          sectionWidth - controller.spacing / 2,
          controller.data[i].height,
        ),
      );
    }
  }

  void _drawBar(Canvas canvas, Paint paint, Rect rect) {
    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(30)),
    );
    paths.add(path);
    canvas.drawPath(path, paint);
  }

  void _drawBarBg(Canvas canvas, Paint paint, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(30)),
      paint,
    );
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
