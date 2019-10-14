import 'package:flutter/animation.dart';

class ChartTween<ChartType> extends Tween<ChartType> {
  ChartTween({ChartType begin, ChartType end}) : super(begin: begin, end: end);

  @override
  ChartType lerp(double t);
}
