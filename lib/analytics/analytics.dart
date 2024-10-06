import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_evm/home_page/home_page.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<Map<String, dynamic>> voteRecords = [];
  DateTime? selectedDate;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
    fetchVoteRecords();
  }

Future<void> fetchVoteRecords() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String espId = prefs.getString("espId") ?? "";

    DatabaseEvent event = await database.child(espId).once();
    if (event.snapshot.value != null) {
      Map data = event.snapshot.value as Map;
      setState(() {
        voteRecords = []; // Initialize to an empty list
        if (data.containsKey('vote_details')) {
          Map<dynamic, dynamic> voteDetailsMap = data['vote_details'] as Map<dynamic, dynamic>;
          voteDetailsMap.forEach((key, detail) {
            var timestampValue = detail['timestamp'];
            
            // If the timestamp is a string in a different format (e.g., ISO 8601)
            DateTime timestamp = DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(timestampValue);
            voteRecords.add({"timestamp": timestamp});
          });
        }
      });
    } else {
      // No data case
      setState(() {
        voteRecords = []; // Ensure it's empty
      });
    }
  } catch (e) {
    print('Error fetching data: $e');
    // Handle errors as needed
  }
}

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateStr = prefs.getString('selectedDate');
    if (dateStr != null) {
      setState(() {
        selectedDate = DateTime.parse(dateStr);
      });
    }
  }

  Future<void> saveSharedPreferences(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', date.toIso8601String());
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Map<String, dynamic>> filterVoteRecordsByDate() {
    if (selectedDate == null) return [];
    return voteRecords.where((record) {
      return isSameDate(record['timestamp'], selectedDate!);
    }).toList();
  }

  List<FlSpot> getHourlyVoteData() {
    Map<int, int> hourlyVotes = {};
    List<Map<String, dynamic>> filteredRecords = filterVoteRecordsByDate();

    for (var record in filteredRecords) {
      DateTime timestamp = record['timestamp'];
      int hour = timestamp.hour;
      hourlyVotes[hour] = (hourlyVotes[hour] ?? 0) + 1;
    }

    return List.generate(24, (index) {
      return FlSpot(index.toDouble(), (hourlyVotes[index] ?? 0).toDouble());
    });
  }

  double getMaxYValue() {
    List<FlSpot> hourlyVotes = getHourlyVoteData();
    double maxVote = hourlyVotes.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxVote + 1; // Adding 1 for a better visual gap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // Top Header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xff0245a4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.keyboard_double_arrow_left,
                        color: Colors.white, size: 40),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("MOUNT ZION SILVER JUBILEE SCHOOL",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text("GRAPH",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Date Picker
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    saveSharedPreferences(pickedDate);
                    fetchVoteRecords();
                  });
                }
              },
              child: Text(
                selectedDate != null
                    ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                    : 'Select Date',
              ),
            ),
          ),
          // Display messages or graph for vote records
          Expanded(
            child: selectedDate == null
                ? const Center(
                    child: Text("Please pick a date",
                        style: TextStyle(color: Colors.white)))
                : voteRecords.isEmpty
                    ? const Center(
                        child: Text("No data available",
                            style: TextStyle(color: Colors.white)))
                    : Padding(
                        padding: const EdgeInsets.all(40),
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval:
                                      1, // Set an interval to display every count
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 == 0) {
                                      return Text(
                                        '${value.toInt()}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      );
                                    }
                                    return Container(); // Return an empty container for other values
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}:00',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: getHourlyVoteData(),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            maxY:
                                getMaxYValue(), // Specify max Y value based on your data
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
