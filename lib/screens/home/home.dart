import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final ScrollController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // Center the text
      child: const Text(
        'Home', // Display the title 'name'
        style: TextStyle(
          fontSize: 24, // Customize the text size
          fontWeight: FontWeight.bold, // Optional: make the text bold
        ),
      ),
    );
  }
}
