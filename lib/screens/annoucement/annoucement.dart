import 'package:flutter/material.dart';

class AnnoucementPage extends StatefulWidget {
  final ScrollController controller;

  const AnnoucementPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<AnnoucementPage> createState() => _AnnoucementPageState();
}

class _AnnoucementPageState extends State<AnnoucementPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // Center the text
      child: const Text(
        'Annoucement', // Display the title 'name'
        style: TextStyle(
          fontSize: 24, // Customize the text size
          fontWeight: FontWeight.bold, // Optional: make the text bold
        ),
      ),
    );
  }
}
