import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_evm/home_page/home_page.dart';
import 'package:smart_evm/manual/info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _espIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); // Check login status on startup
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String espId = prefs.getString('espId') ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CandidateListPage(espId: espId)),
      );
    }
  }

  Future<void> _login() async {
    String espId = _espIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      DataSnapshot snapshot = await _database.child(espId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        if (userData['password'] == password) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful for $espId!')),
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('espId', espId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CandidateListPage(espId: espId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ESP ID not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching data from Firebase')),
      );
    }
  }

  // Method to display the dialog with the PDF content
   void _showManualDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Use MediaQuery to get the screen size
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      return AlertDialog(
        backgroundColor: Color(0xff240046), // Dark purple background color matching the app
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        // Set the dialog's height and width to be slightly smaller than the screen size
        contentPadding: EdgeInsets.zero, // No padding around the dialog
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Slight padding around dialog
        titlePadding: const EdgeInsets.all(20), // Padding for the title
        title: const Text(
          "User Manual",
          style: TextStyle(
            color: Colors.white, // White title text to contrast the dark background
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        content: Container(
          height: screenHeight * 0.85, // 85% of screen height
          width: screenWidth * 0.95, // 95% of screen width
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding inside the dialog
          decoration: BoxDecoration(
            color: Color(0xff3e065f), // Slightly lighter purple for the content area
            borderRadius: BorderRadius.circular(20.0), // Match the rounded corners of the dialog
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // Padding inside the scrollable content
              child: Text(
                Info().info, // The manual text
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70, // Off-white text for readability
                  height: 1.5, // Line height for readability
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                backgroundColor: Color(0xff7A1CAC), // Button color matching the gradient in the app
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Close",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White button text for contrast
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        leading: IconButton(
          icon: Icon(Icons.info),
          tooltip: 'Download Manual',
          onPressed: () {
            _showManualDialog(context); // Show the manual when pressed
          },
        ),
      ),
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff10002b), Color(0xff7A1CAC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.55, 1],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "MOUNT ZION SILVER JUBILEE SCHOOL",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "ELECTION PORTAL",
                  style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _espIdController,
                    style: const TextStyle(color: Colors.white),
                    decoration:const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      labelText: 'ESP ID',
                      hintText: 'Enter ESP ID',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration:const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1.5),
                      ),
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
