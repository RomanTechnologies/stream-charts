import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'charts_example_bloc.dart';
import 'package:stream_charts/stream_charts.dart';

class ChartsExamplePage extends StatefulWidget {
  static Widget withData() {
    return Provider<ChartsExampleBloc>(
      builder: (ctx) => ChartsExampleBloc(),
      child: ChartsExamplePage(),
      dispose: (ctx, bloc) => bloc.dispose(),
    );
  }

  @override
  ChartsExamplePageState createState() => ChartsExamplePageState();
}

class ChartsExamplePageState extends State<ChartsExamplePage> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<ChartsExampleBloc>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BarChart(controllerStream: bloc.barChartControllerStream),
            PieChart(
              controllerStream: bloc.pieChartControllerStream,
              child: _buildPieCenter(),
              onSelect: bloc.pieChartControllerSubject.add,
            ),
            LineGraph(controllerStream: bloc.lineGraphControllerStream),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async => await _randomise()),
    );
  }

  Widget _buildPieCenter() {
    final bloc = Provider.of<ChartsExampleBloc>(context);
    return StreamBuilder<PieChartController>(
      stream: bloc.pieChartControllerStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "${snapshot.data.segments.length} segments",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Selected ${snapshot.data.selected}",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _randomise() async {
    await _randomiseBars();
    await _randomisePie();
    await _randomiseLines();
  }

  Future<void> _randomiseBars() async {
    Random random = Random();
    final bloc = Provider.of<ChartsExampleBloc>(context);

    BarChartController barChartController = bloc.barChartControllerSubject.value;
    barChartController = barChartController.copyWith(
      spacing: random.nextInt(100).toDouble(),
      showBarBg: false,
      bars: bloc.barChartControllerSubject?.value?.bars
              ?.map(
                (bar) => bar.copyWith(
                  height: random.nextInt(400).toDouble(),
                  color: Color.fromRGBO(
                    0 + random.nextInt(255),
                    0 + random.nextInt(255),
                    0 + random.nextInt(255),
                    1,
                  ),
                ),
              )
              ?.toList() ??
          [],
    );

    bloc.barChartControllerSubject.add(barChartController);
  }

  Future<void> _randomisePie() async {
    final bloc = Provider.of<ChartsExampleBloc>(context);

    PieChartController pieChartController = bloc.pieChartControllerSubject.value;

    List<PieData> segments = PieData.randomSet(
      minLength: 2,
      maxLength: 15,
      maxRadius: 100,
      maxValue: 100,
      fixedRadius: false,
    );

    segments.sort((b, a) => b.value.compareTo(a.value));

    pieChartController = pieChartController.copyWith(
      segments: segments,
      rounded: false,
      threeD: false,
      startOffset: -3.142 / 2,
//      segmentPadding: random.nextInt(20).toDouble(),
      segmentPadding: 5,
//      centerRadius: random.nextInt(150).toDouble(),
      centerRadius: 100,
//      segmentWidth: random.nextInt(150).toDouble(),
      segmentWidth: 70,
      selectedWidth: 100,
    );
    bloc.pieChartControllerSubject.add(pieChartController);
  }

  Future<void> _randomiseLines() async {
    Random random = Random();
    final bloc = Provider.of<ChartsExampleBloc>(context);

    LineGraphController lineGraphController = bloc.lineGraphControllerSubject.value;

    List<LineData> lines = lineGraphController.lines.map((line) {
      List<PointData> points = line.points.map((point) {
            return point.copyWith(
                x: (point.x * random.nextDouble()) + (200 * random.nextDouble()),
                y: (point.y * random.nextDouble()) + (200 * random.nextDouble()),
                size: random.nextInt(10).toDouble(),
                color: Color.fromRGBO(
                  0 + random.nextInt(255),
                  0 + random.nextInt(255),
                  0 + random.nextInt(255),
                  1,
                ));
          }).toList() ??
          [];

      points.sort((PointData a, PointData b) => a.x.compareTo(b.x));

      return line.copyWith(
        points: points,
        smoothness: .5,
        shouldCurve: true,
        roundedEnds: true,
        overflow: true,
        color: Color.fromRGBO(
          50 + random.nextInt(100),
          50 + random.nextInt(100),
          50 + random.nextInt(100),
          1,
        ),
      );
    }).toList();

    lineGraphController = lineGraphController.copyWith(
      lines: lines,
    );

    bloc.lineGraphControllerSubject.add(lineGraphController);
  }
}
