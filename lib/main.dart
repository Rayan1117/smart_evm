import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_evm/firebase_options.dart';
import 'package:smart_evm/home_page/home_page.dart';
import 'package:smart_evm/login_page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? espId = prefs.getString('espId');

  runApp(MyApp(isLoggedIn: isLoggedIn, espId: espId));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? espId;

  const MyApp({super.key, required this.isLoggedIn, this.espId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart EVM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn
          ? CandidateListPage(espId: espId) // If logged in, navigate to CandidateListPage
          : const LoginPage(), // If not logged in, navigate to LoginPage
      debugShowCheckedModeBanner: false,
    );
  }
}
