import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<Map<String, String>> voteRecords = [];
  DateTime? selectedDate;
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  
  @override
  void initState() {
    super.initState();
    loadSharedPreferences(); // Load saved state (selected date)
    fetchVoteRecords();  // Fetch the vote records when the widget initializes
  }

  // Fetch vote records from Firebase Realtime Database
  Future<void> fetchVoteRecords() async {
    try {
      DatabaseEvent event = await database.child('voteData').once();
      Map data = event.snapshot.value as Map;
      
      setState(() {
        voteRecords = []; // Reset records
        data.forEach((key, value) {
          List<String> candidateNames = value['candidate_names'].toString().split(',');
          List<String> voteCounts = value['vote_count'].toString().split(',');

          for (int i = 0; i < candidateNames.length; i++) {
            voteRecords.add({
              "candidate": candidateNames[i],
              "vote_count": voteCounts[i],
              "esp8266Id": key, // Assuming ESP key is the unique identifier
            });
          }
        });
      });
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

  // Navigate to EspVotesPage (if applicable)
  void navigateToEspVotesPage() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EspVotesPage(
    //       espVotes: getVotesPerEspId(),
    //       selectedDate: selectedDate != null ? _formatDate(selectedDate!) : null,
    //     ),
    //   ),
    // );
  }

  // Extract vote counts per ESP
  Map<String, int> getVotesPerEspId() {
    Map<String, int> espVotes = {};

    for (var vote in voteRecords) {
      String espId = vote["esp8266Id"] ?? '';
      if (espId.isNotEmpty) {
        espVotes[espId] = (espVotes[espId] ?? 0) + int.parse(vote["vote_count"]!);
      }
    }

    return espVotes;
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
                    onPressed: () { Navigator.pop(context); },
                    icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white, size: 40),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "MOUNT ZION SILVER JUBILEE SCHOOL",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "GRAPH",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: navigateToEspVotesPage,
                    icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 40),
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
                    saveSharedPreferences(pickedDate); // Save date in shared preferences
                  });
                }
              },
              child: Text(
                selectedDate != null
                    ? 'Selected Date: ${_formatDate(selectedDate!)}'
                    : 'Select Date',
              ),
            ),
          ),
          // Show vote records
          Expanded(
            child: voteRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: voteRecords.length,
                    itemBuilder: (context, index) {
                      final record = voteRecords[index];
                      return ListTile(
                        title: Text(record['candidate']!, style: const TextStyle(color: Colors.white)),
                        subtitle: Text("Vote count: ${record['vote_count']}", style: const TextStyle(color: Colors.white)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
