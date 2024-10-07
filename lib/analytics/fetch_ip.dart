import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchIPScreen extends StatefulWidget {
  const FetchIPScreen({Key? key}) : super(key: key);

  @override
  _FetchIPScreenState createState() => _FetchIPScreenState();
}

class _FetchIPScreenState extends State<FetchIPScreen> {
  String? ipAddress;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchIPAddress();
  }

  Future<void> fetchIPAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String espId = prefs.getString("espId") ?? "";

      DatabaseEvent event = await database.child(espId).child('ip').once();
      if (event.snapshot.value != null) {
        setState(() {
          ipAddress = event.snapshot.value.toString();
        });
      } else {
        setState(() {
          ipAddress = "No IP found";
        });
      }
    } catch (e) {
      print("Error fetching IP: $e");
      setState(() {
        ipAddress = "Error fetching IP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fetch IP Address"),
      ),
      body: Center(
        child: ipAddress == null
            ? const CircularProgressIndicator()
            : Text(
                'IP Address: $ipAddress',
                style: const TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
