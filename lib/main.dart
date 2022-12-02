import 'package:flutter/material.dart';
import 'package:quickcheck/pages/home_page.dart';

void main() {
  // run the app
  runApp(const App());
}

/// The main app of the application; serves as a wrapper for a MaterialApp and loads HomePage
class App extends StatelessWidget {
  /// The main app of the application; serves as a wrapper for a MaterialApp and loads HomePage
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
