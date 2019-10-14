abstract class ChartController<ChartData> {
  ChartController({this.data});

  final List<ChartData> data;

  ChartController copyWith();
}
