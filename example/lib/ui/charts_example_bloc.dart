import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_charts/stream_charts.dart';

class ChartsExampleBloc {
  BehaviorSubject<BarChartController> barChartControllerSubject = BehaviorSubject<BarChartController>.seeded(BarChartController(
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
  ));
  Observable<BarChartController> get barChartControllerStream => barChartControllerSubject.stream;

  BehaviorSubject<PieChartController> pieChartControllerSubject = BehaviorSubject<PieChartController>.seeded(PieChartController.empty());
  Observable<PieChartController> get pieChartControllerStream => pieChartControllerSubject.stream;

  BehaviorSubject<LineGraphController> lineGraphControllerSubject = BehaviorSubject<LineGraphController>.seeded(LineGraphController(
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
  ));
  Observable<LineGraphController> get lineGraphControllerStream => lineGraphControllerSubject.stream;

  void dispose() {
    barChartControllerSubject.close();
    pieChartControllerSubject.close();
    lineGraphControllerSubject.close();
  }
}
