import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_evm/home_page/home_page.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for ESP ID and password
  final TextEditingController _espIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Firebase database reference
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check login status on startup
  }

  // Function to check login status
  Future<void> checkLoginStatus() async {
    final Box box = Hive.box('myBox');
    bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    if (isLoggedIn) {
      String espId = box.get('espId', defaultValue: '');
      // Navigate to the CandidateListPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CandidateListPage(espId: espId)),
      );
    }
  }

  // Function to handle login
  Future<void> _login() async {
    String espId = _espIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Fetch user data from Firebase based on ESP ID
      DataSnapshot snapshot = await _database.child(espId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

        // Validate the password
        if (userData['password'] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful for $espId!')),
          );

          // Store login state in Hive
          final Box box = Hive.box('myBox');
          await box.put('isLoggedIn', true);
          await box.put('espId', espId); // Store ESP ID

          // Navigate to the CandidateListPage and pass the data
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CandidateListPage(espId: espId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ESP ID not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data from Firebase')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff10002b), Color(0xff7A1CAC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.55, 1],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "MOUNT ZION SILVER JUBILEE SCHOOL",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "ELECTION PORTAL",
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(0xff240046),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.30),
            // Simple container instead of Glassmorph
            Container(
              width: MediaQuery.of(context).size.width < 800
                  ? MediaQuery.of(context).size.width * 0.45
                  : MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _espIdController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 1.5),
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 1.5),
                          ),
                          labelText: 'ESP ID',
                          hintText: 'Enter Your ESP ID',
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _passwordController,
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 1.5),
                          ),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 5.0, right: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
