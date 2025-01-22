import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:page_transition/page_transition.dart';

class DiscoverPage extends StatefulWidget {
  final ScrollController controller;

  const DiscoverPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            floating: true,
            snap: true,
            surfaceTintColor: Colors.transparent,
            title:  Row(
              children: [
                 Text(
                  " | Event",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      body: Container(
        alignment: Alignment.center, // Center the text
        child: const Text(
          'Event', // Display the title 'name'
          style: TextStyle(
            fontSize: 24, // Customize the text size
            fontWeight: FontWeight.bold, // Optional: make the text bold
          ),
        ),
      ),
    );
  }
}
