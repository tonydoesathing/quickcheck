import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuickCheck"),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Add Student"))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Add Assessment"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [const Text("Table goes here")],
        ),
      ),
    );
  }
}
