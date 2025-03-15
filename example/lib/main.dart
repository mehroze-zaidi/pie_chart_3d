import 'package:flutter/material.dart';
import 'package:pie_chart_3d/pie_chart_3d.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ExampleApp();
      },
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ThreeDPieChart(
          data: _getChartData(),
          options: PieChartOptions(
            height: 400,
            width: 400,
            depthDarkness: 0.9,
            ellipseRatio: 0.4,
            shadowHeight: 50,
          ),
        ),
      ),
    );
  }

  List<ChartData> _getChartData() {
    return [
      ChartData(category: 'Music', value: 80, color: Color(0xFF6366F1)),
      ChartData(category: 'Sport', value: 50, color: Color(0xFFEF4444)),
      ChartData(category: 'School', value: 50, color: Color(0xFFFACC15)),
      ChartData(category: 'ART', value: 15, color: Color(0xFFC115FA)),
      ChartData(category: 'FOOD', value: 20, color: Color(0xFF56B533)),
    ];
  }
}
