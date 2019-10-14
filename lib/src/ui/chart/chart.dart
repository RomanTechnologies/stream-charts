import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/chart/data.dart';
import 'package:stream_charts/src/ui/chart/painter.dart';
import 'package:stream_charts/src/ui/chart/tween.dart';

abstract class Chart extends StatefulWidget {
  Chart({
    Key key,
    this.controllerStream,
    this.child,
    this.onSelect,
  }) : super(key: key);

  final Stream<dynamic> controllerStream;
  final Widget child;
  final Function onSelect;
}

abstract class ChartState<Page extends Chart> extends State<Chart> with TickerProviderStateMixin {
  AnimationController animation;
  ChartTween tween;
  ChartPainter painter();

  void setup() {
    animation = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    animation.forward();
  }

  void updateData(ChartController<ChartData> data) {
    animation.forward(from: 0.0);
  }
}

mixin ChartPage<Page extends Chart> on ChartState<Page> {
  @override
  void initState() {
    super.initState();
    setup();

    widget.controllerStream.listen((data) {
      updateData(data);
    });
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomPaint(
      size: Size(screenWidth, screenWidth),
      painter: painter(),
    );
  }

  void selectChart(ChartController controller, int selectedIndex) async {}
}
