import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CandidateListPage extends StatefulWidget {
  final String espId;

  CandidateListPage({required this.espId});

  @override
  _CandidateListPageState createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> {
  late DatabaseReference _databaseRef;
  List<String> candidateNames = [];
  List<int> voteCounts = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize Firebase database reference for the specific ESP ID
    _databaseRef = FirebaseDatabase.instance.ref(widget.espId);
    
    // Fetch candidate data from Firebase
    _fetchCandidateData();
  }

  // Function to fetch candidate names and vote counts from Firebase
  void _fetchCandidateData() async {
    // Get the data from the Firebase reference
    DataSnapshot snapshot = await _databaseRef.get();

    if (snapshot.exists) {
      // Extract data
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // Split candidate names and vote counts into lists
      if (data['candidate_names'] != null && data['vote_count'] != null) {
        setState(() {
          candidateNames = (data['candidate_names'] as String).split(',');
          voteCounts = (data['vote_count'] as String)
              .split(',')
              .map(int.parse) // Convert each string vote count to int
              .toList();
        });
      }
    } else {
      // Handle case when the snapshot does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No candidates found for this ESP ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Candidate List')),
      body: candidateNames.isNotEmpty
          ? ListView.builder(
              itemCount: candidateNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(candidateNames[index]),
                  subtitle: Text('Votes: ${voteCounts[index]}'),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
