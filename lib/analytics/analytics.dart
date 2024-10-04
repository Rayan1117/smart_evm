import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the chart library
import 'package:intl/intl.dart'; // For date formatting

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
    loadSharedPreferences(); // Load saved state (selected date)
    fetchVoteRecords(); // Fetch the vote records when the widget initializes
  }

  // Fetch vote records from Firebase Realtime Database
  Future<void> fetchVoteRecords() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String espId = pref.getString("espId") ?? "";
      print("Selected ESP ID: $espId");

      DatabaseEvent event = await database.child(espId).once();

      if (event.snapshot.value != null) {
        Map data = event.snapshot.value as Map;
        print("Fetched data: $data");

        setState(() {
          voteRecords = []; // Reset records

          // Navigate through the data structure
          if (data.containsKey('vote_details')) {
            List<dynamic> voteDetails = data['vote_details'] as List<dynamic>;

            // Loop through each entry in vote_details
            for (var detail in voteDetails) {
              // Extract timestamp from each detail
              DateTime timestamp = DateTime.parse(detail['timestamp']);
              print("Vote timestamp: $timestamp");

              // Create a model for each vote's timestamp
              voteRecords.add({
                "vote_no": voteRecords.length, // Use the current length as the vote number
                "timestamp": timestamp, // Store the timestamp
              });
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Load selected date from SharedPreferences
  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateStr = prefs.getString('selectedDate');
    if (dateStr != null) {
      setState(() {
        selectedDate = DateTime.parse(dateStr);
      });
    }
  }

  // Save selected date in SharedPreferences
  Future<void> saveSharedPreferences(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', date.toIso8601String());
  }

  // Check if two dates are the same
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Group votes by 1-hour intervals
  List<BarChartGroupData> getHourlyVoteData() {
    Map<int, int> hourlyVotes = {};

    for (var record in voteRecords) {
      DateTime timestamp = record['timestamp'];
      int hour = timestamp.hour;

      hourlyVotes[hour] = (hourlyVotes[hour] ?? 0) + 1;
    }

    // Convert to BarChartGroupData
    return hourlyVotes.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key, // Hour of the day (0 to 23)
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(), // Number of votes
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          // Top Header and Navigation to EspVotesPage
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: const Color(0xff0245a4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.keyboard_double_arrow_left,
                        color: Colors.white, size: 40),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "MOUNT ZION SILVER JUBILEE SCHOOL",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "GRAPH",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
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
                    saveSharedPreferences(
                        pickedDate); // Save date in shared preferences
                    fetchVoteRecords(); // Re-fetch records for new date
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
          // Display graph for vote records
          Expanded(
            child: voteRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: getHourlyVoteData(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Show hours as titles on the x-axis
                                return Text('${value.toInt()}:00',
                                    style:
                                        const TextStyle(color: Colors.white));
                              },
                              reservedSize: 30,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    )),

          ),
        ],
      ),
    );
  }
}
