import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  final dbRef = FirebaseDatabase.instance.ref("air_history");

  List<FlSpot> gasPoints = [];

  @override
  void initState() {
    super.initState();

    dbRef.limitToLast(20).onValue.listen((event){

      final data = event.snapshot.value;

      if(data == null) return;

      Map map = data as Map;

      List values = map.values.toList();

      gasPoints.clear();

      for(int i=0;i<values.length;i++){

        double gas = (values[i]["gas"]).toDouble();

        gasPoints.add(
            FlSpot(i.toDouble(), gas)
        );

      }

      setState(() {});

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Gas History"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: LineChart(

          LineChartData(

            lineBarsData: [

              LineChartBarData(
                spots: gasPoints,
                isCurved: true,
                barWidth: 3,
              )

            ],

          ),

        ),

      ),

    );
  }
}