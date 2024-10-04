import 'dart:async'; // Import the async package for Timer
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_evm/analytics/analytics.dart';

class CandidateListPage extends StatefulWidget {
  final String? espId;

  const CandidateListPage({super.key, this.espId});

  @override
  _CandidateListPageState createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> {
  late DatabaseReference _databaseRef;
  List<String> vicecandidate_name=[];
  List<String> candidateNames = [];
  List<String> voteCounts = [];
  String? espId;

  final int maxVotes = 400; // Initialize the maximum votes
  int totalPolledVotes = 0; // Variable to hold total polled votes
  Timer? _timer; // Timer for periodic fetching

  @override
  void initState() {
    super.initState();
    _loadEspId();
  }

  Future<void> _loadEspId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    espId = widget.espId ?? prefs.getString('espId');

    if (espId != null) {
      _databaseRef = FirebaseDatabase.instance.ref().child(espId!);
      _fetchCandidates(); // Initial fetch for candidates
      _startPeriodicFetch(); // Start fetching data every 2 seconds
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ESP ID not found')),
      );
    }
  }

  Future<void> _fetchCandidates() async {
    DataSnapshot snapshot = await _databaseRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        vicecandidate_name=data['vicecandidate_names'].split(',');
        candidateNames = data['candidate_names'].split(',');
        voteCounts = data['vote_count'].split(',');
        // Calculate total polled votes
        totalPolledVotes = voteCounts.map(int.parse).reduce((a, b) => a + b);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No candidates found for this ESP ID')),
      );
    }
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      _fetchCandidates(); // Fetch candidates every 2 seconds
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Widget tile(String name,String vicename, String votes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        height: 100,
        decoration:const BoxDecoration(
          color:  Color(0xffffdec0),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        vicename,
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    votes,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Candidates List'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Analytics(),
                ), // Navigate to Analytics
              );
            },
            child: const Text("Go to Analytics"),
          ),
        ],
        backgroundColor: const Color(0xff0245a4),
      ),
      body: espId == null
          ? const Center(
              child: Text('Error: ESP ID not found.'),
            )
          :( candidateNames.isNotEmpty && vicecandidate_name.isNotEmpty)
              ? ListView.builder(
                  itemCount: candidateNames.length,
                  itemBuilder: (context, index) {
                    return tile(candidateNames[index],vicecandidate_name[index], voteCounts[index]);
                  },
                )
              : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        color: const Color(0xff0245a4),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Max Votes: $maxVotes',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Votes Polled: $totalPolledVotes',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Remaining: ${maxVotes - totalPolledVotes}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
