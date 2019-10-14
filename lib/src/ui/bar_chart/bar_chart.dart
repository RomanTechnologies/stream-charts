import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/bar_chart/bar.dart';
import 'package:stream_charts/src/ui/chart/chart.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';

class BarChart extends Chart {
  BarChart({Key key, Stream<BarChartController> controllerStream})
      : super(key: key, controllerStream: controllerStream);

  @override
  BarChartState createState() => BarChartState();
}

class BarChartState extends ChartState<BarChart> with ChartPage {
  @override
  painter() => BarChartPainter(
        animation: tween.animate(animation),
        onSelect: selectChart,
      );

  @override
  void setup() {
    tween = BarTween(
      Bar(controller: barChartController),
      Bar(controller: barChartController),
    );

    super.setup();
  }

  @override
  void updateData(ChartController data) {
    setState(() {
      tween = BarTween(
        tween.evaluate(animation),
        Bar(controller: data as BarChartController),
      );
    });
    super.updateData(data);
  }

  BarChartController barChartController = BarChartController(
    bars: [
      BarData(
        height: 165,
        color: Colors.green,
        group: "First",
      ),
      BarData(
        height: 97,
        color: Colors.blueAccent,
        group: "First",
      ),
      BarData(
        height: 270,
        color: Colors.lightBlue,
        group: "Second",
      ),
      BarData(
        height: 230,
        color: Colors.blueAccent,
        group: "First",
      ),
      BarData(
        height: 79,
        color: Colors.blueAccent,
        group: "First",
      ),
      BarData(
        height: 133,
        color: Colors.lightBlue,
        group: "Second",
      ),
      BarData(
        height: 54,
        color: Colors.blueAccent,
        group: "First",
      ),
    ],
    spacing: 25,
    showBarBg: false,
  );

  @override
  void selectChart(ChartController controller, int selectedIndex) {
    print("SELECTED INDEX: $selectedIndex");
  }
}
