import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:new_dental/services/api_services.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedFilter = 'disease';
  List<dynamic> chartData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/admin/stats.php?filter=$selectedFilter'));
    if (response.statusCode == 200) {
      setState(() {
        chartData = json.decode(response.body)['data'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DropdownButton<String>(
              value: selectedFilter,
              items: [
                DropdownMenuItem(value: "disease", child: Text("Disease Statistics")),
                DropdownMenuItem(value: "college", child: Text("College Statistics")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                fetchData();
              },
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: selectedFilter == 'disease' ? buildDiseaseGrid() : buildCollegePieChart(),
          ),
        ],
      ),
    );
  }

  /// 🦷 **Disease Statistics - Grid Layout**
  Widget buildDiseaseGrid() {
    if (chartData.isEmpty) {
      return Center(child: Text("No disease data available"));
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 4 boxes per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2, // Adjust for better fit
        ),
        itemCount: chartData.length,
        itemBuilder: (context, index) {
          var item = chartData[index];
          return Container(
            decoration: BoxDecoration(
              color: getRandomColor(index),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['disease_name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Count: ${item['count'] ?? 0}",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🏫 **College Statistics - Pie Chart**
  Widget buildCollegePieChart() {
    if (chartData.isEmpty) {
      return Center(child: Text("No college data available"));
    }

    List<PieChartSectionData> sections = chartData.asMap().entries.map((entry) {
      int index = entry.key;
      var item = entry.value;
      return PieChartSectionData(
        color: getRandomColor(index),
        value: (item['count'] ?? 0).toDouble(),
        title: item['college_name'] ?? 'Unknown',
        radius: 100,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return InteractiveViewer(
      boundaryMargin: EdgeInsets.all(20),
      minScale: 0.8,
      maxScale: 3.0,
      child: SizedBox(
        width: 400,
        height: 400,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 50,
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  /// 🎨 **Generate Random Colors**
  Color getRandomColor(int index) {
    final Random random = Random(index);
    return Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      1,
    );
  }
}
