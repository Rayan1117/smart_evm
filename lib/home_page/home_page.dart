import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_evm/analytics/analytics.dart';

class CandidateListPage extends StatefulWidget {
  final String? espId;

  const CandidateListPage({Key? key, this.espId}) : super(key: key);

  @override
  _CandidateListPageState createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> {
  late DatabaseReference _databaseRef;
  List<String> candidateNames = [];
  List<String> voteCounts = [];
  String? espId;

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
      _fetchCandidates();
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
        candidateNames = data['candidate_names'].split(',');
        voteCounts = data['vote_count'].split(',');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No candidates found for this ESP ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Analytics()), // Navigate to Analytics
              );
            },
            child: const Text("Go to Analytics"),
          ),
        ],
        title: const Text('Candidates List'),
      ),
      body: espId == null
          ? const Center(child: Text('Error: ESP ID not found.'))
          : candidateNames.isNotEmpty
              ? ListView.builder(
                  itemCount: candidateNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(candidateNames[index]),
                      subtitle: Text('Votes: ${voteCounts[index]}'),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
