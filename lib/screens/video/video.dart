import 'package:flutter/material.dart';

class VideoPage extends StatefulWidget {

  final ScrollController controller;

  const VideoPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center, // Center the text
      child: const Text(
        'Video', // Display the title 'name'
        style: TextStyle(
          fontSize: 24, // Customize the text size
          fontWeight: FontWeight.bold, // Optional: make the text bold
        ),
      ),
    );
  }
}
