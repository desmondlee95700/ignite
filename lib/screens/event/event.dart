import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {

  final ScrollController controller;

  const DiscoverPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // Center the text
      child: const Text(
        'Event', // Display the title 'name'
        style: TextStyle(
          fontSize: 24, // Customize the text size
          fontWeight: FontWeight.bold, // Optional: make the text bold
        ),
      ),
    );
  }
}
