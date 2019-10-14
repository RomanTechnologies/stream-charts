import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/type.dart';

abstract class ChartPainter extends CustomPainter {
  ChartPainter({
    this.animation,
    this.onSelect,
  }) : super(repaint: animation) {
    paths = [];
  }

  final Animation<ChartType> animation;
  final Function onSelect;

  List<Path> paths = [];

  @override
  void paint(Canvas canvas, Size size) {
    paths = [];
  }

  @override
  bool hitTest(Offset position) {
    // Check all added paths

    for (int i = 0; i < paths.length; i++) {
      paths[i].fillType = PathFillType.nonZero;
      if (paths[i].contains(position)) {
        print("Path with index: $i selected at $position");
        onSelect(animation.value.controller, i);
        return true;
      }
    }
    print("Chart touched at $position");
    return false;
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    paths = [];
    return oldDelegate.animation != animation;
  }
}
