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
  List<String> vicecandidate_name = [];
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
        vicecandidate_name = data['vicecandidate_names'].split(',');
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

  List<String> image = [
    'assets/c1.jpeg.jpg',
    'assets/c2.jpeg.jpg',
    'assets/c3.jpeg.jpg',
    'assets/c4.jpeg.jpg',
    'assets/c5.jpeg.jpg',
    'assets/c6.jpeg.jpg',
    'assets/c7.jpeg.jpg',
    'assets/c2.jpeg.jpg'
  ];

  Widget tile(String name, String vicename, String img, String votes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: Color(0xff240046), // Update to match reference color
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 60), // Same as in the reference code
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 12, top: 8, bottom: 8),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(img),
                backgroundColor: Colors.yellow, // Placeholder for image
                child: img.isEmpty
                    ? Text(
                        name[0], // First letter of name if no image is provided
                        style:
                            const TextStyle(color: Colors.black, fontSize: 30),
                      )
                    : null, // No child if image is provided
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "$name\n$vicename",
                  style: const TextStyle(
                    color: Colors.yellow, // Reference style
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "VOTES",
                    style: TextStyle(
                      color: Colors.yellow, // Reference style
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    votes,
                    style: const TextStyle(
                      color: Colors.white, // Same as reference
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(width: 120),
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
      backgroundColor:
          const Color(0xff10002b), // Update to match reference background
      appBar: AppBar(
        title: const Text(
          'MountZion Silver Jubilee School',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Analytics(),
                ), // Navigate to Analytics
              );
            },
            icon: const Icon(Icons.auto_graph_sharp,
                color: Colors.white, size: 40), // Updated style
          ),
        ],
        backgroundColor:
            const Color(0xff240046), // Update to match reference color
      ),
      body: espId == null
          ? const Center(
              child: Text('Error: ESP ID not found.',
                  style: TextStyle(color: Colors.white)), // Reference styling
            )
          : (candidateNames.isNotEmpty && vicecandidate_name.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: candidateNames.length,
                    itemBuilder: (context, index) {
                      return tile(
                          candidateNames[index],
                          vicecandidate_name[index],
                          image[index],
                          voteCounts[index]);
                    },
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                      color: Colors.yellow)), // Update loader color
      bottomNavigationBar: Container(
        color: const Color(0xff240046), // Update to match reference style
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Max Votes: $maxVotes',
              style: const TextStyle(
                  color: Colors.white), // Match reference text color
            ),
            Text(
              'Votes Polled: $totalPolledVotes',
              style: const TextStyle(
                  color: Colors.white), // Match reference text color
            ),
            Text(
              'Remaining: ${maxVotes - totalPolledVotes}',
              style: const TextStyle(
                  color: Colors.white), // Match reference text color
            ),
          ],
        ),
      ),
    );
  }
}
