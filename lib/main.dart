import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ietpapp/features/pages/signup.dart';
import 'package:ietpapp/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garbage System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Signup(),
    );
  }
}
