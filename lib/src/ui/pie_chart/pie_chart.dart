import 'package:flutter/material.dart';
import 'package:stream_charts/src/ui/chart/chart.dart';
import 'package:stream_charts/src/ui/chart/controller.dart';
import 'package:stream_charts/src/ui/pie_chart/pie.dart';

class PieChart extends Chart {
  PieChart({
    Key key,
    Stream<PieChartController> controllerStream,
    Widget child,
    Function onSelect,
  }) : super(key: key, controllerStream: controllerStream, child: child, onSelect: onSelect);

  @override
  PieChartState createState() => PieChartState();
}

class PieChartState extends ChartState<PieChart> with ChartPage {
  @override
  painter() => PieChartPainter(
        animation: tween.animate(animation),
        onSelect: selectChart,
      );

  // Make extendable from base for all
  Map<int, bool> selected;
  double centerRadius = 0.0;

  @override
  void setup() {
    tween = PieTween(
      Pie(controller: PieChartController.empty()),
      Pie(controller: PieChartController.empty()),
    );
    super.setup();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      height: screenWidth,
      child: Stack(
//        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: ClipOval(
              child: SizedBox(
                width: centerRadius * 2,
                height: centerRadius * 2,
                child: widget.child,
              ),
            ),
          ),
          CustomPaint(
            size: Size(screenWidth, screenWidth),
            painter: painter(),
          ),
        ],
      ),
    );
  }

  @override
  void updateData(ChartController data) {
    PieChartController pieChartController = data;
    setState(() {
      centerRadius = pieChartController.centerRadius;
      tween = PieTween(
        tween.evaluate(animation),
        Pie(controller: pieChartController),
      );
    });
    super.updateData(data);
  }

  @override
  void selectChart(ChartController controller, int selectedIndex) {
    print("SELECTED INDEX: $selectedIndex");
    PieChartController pieController = controller as PieChartController;

    if (pieController.selected.containsKey(selectedIndex)) {
      if (pieController.selected[selectedIndex]) {
        pieController.selected[selectedIndex] = false;
      } else {
        pieController.selected[selectedIndex] = true;
      }
    } else {
      pieController.selected[selectedIndex] = true;
    }

    if (widget.onSelect != null) {
      widget.onSelect(pieController.segments[selectedIndex]);
    }
  }
}
