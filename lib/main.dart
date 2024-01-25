import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAnXN4YXgLEbD-syPNyM7vSSxd7pEAZxRI",
        authDomain: "snake-76cc9.firebaseapp.com",
        projectId: "snake-76cc9",
        storageBucket: "snake-76cc9.appspot.com",
        messagingSenderId: "970583793128",
        appId: "1:970583793128:web:33a7080a8e1db2336e985d"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
