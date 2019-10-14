import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/chart.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/line_graph/line.dart';

class LineGraph extends Chart {
  LineGraph({Key key, Stream<LineGraphController> controllerStream})
      : super(key: key, controllerStream: controllerStream);

  @override
  LineGraphState createState() => LineGraphState();
}

class LineGraphState extends ChartState<LineGraph> with ChartPage {
  @override
  painter() => LineGraphPainter(
        animation: tween.animate(animation),
        onSelect: selectChart,
      );

  @override
  void setup() {
    tween = LineTween(
      Line(controller: lineGraphController),
      Line(controller: lineGraphController),
    );
    super.setup();
  }

  @override
  void updateData(ChartController data) {
    setState(() {
      tween = LineTween(
        tween.evaluate(animation),
        Line(controller: data as LineGraphController),
      );
    });
    super.updateData(data);
  }

  @override
  void selectChart(ChartController controller, int selectedIndex) {
    print("SELECTED INDEX: $selectedIndex");
  }

  LineGraphController lineGraphController = LineGraphController(
    lines: [
      LineData(
        points: [
          PointData(x: 100, y: 250, color: Colors.blueGrey, size: 7),
          PointData(x: 200, y: 60, color: Colors.blueGrey, size: 7),
          PointData(x: 300, y: 170, color: Colors.blueGrey, size: 7),
          PointData(x: 400, y: 90, color: Colors.blueGrey, size: 7),
        ],
        shouldCurve: true,
        smoothness: .5,
        roundedEnds: true,
        overflow: true,
        color: Colors.blue,
      ),
      LineData(
        points: [
          PointData(x: 50, y: 50, color: Colors.blueGrey, size: 7),
          PointData(x: 150, y: 160, color: Colors.blueGrey, size: 7),
          PointData(x: 250, y: 70, color: Colors.blueGrey, size: 7),
          PointData(x: 350, y: 190, color: Colors.blueGrey, size: 7),
        ],
        shouldCurve: true,
        smoothness: .5,
        roundedEnds: true,
        overflow: true,
        color: Colors.lightBlueAccent,
      ),
    ],
  );
}
