import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_evm/glassmorph/colors.dart';
import 'package:smart_evm/glassmorph/glassmorph.dart';
import 'package:smart_evm/home_page/home_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65.0,
        backgroundColor: barblue,
        title: Center(
            child: Text(
          "NOVOTECH SMART EVM",
          style: TextStyle(
              color: myyellow, fontSize: 35, fontWeight: FontWeight.bold),
        )),
      ),
      backgroundColor: myblue,
      body: Center(
        child: Glassmorph(
          blur: 0.2,
          opacity: 0.2,
          child: Container(
            height: 350, width: 750,
            // Gradient background
            decoration: const BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [Color(0xff10002b), Color(0xff7A1CAC)],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                //   stops: [0.55, 1],
                // ),
                ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _espIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'ESP ID',
                          hintText: 'Enter ESP ID',
                          hintStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
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
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.5),
                          ),
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: myyellow,
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
        ),
      ),
    );
  }
}
