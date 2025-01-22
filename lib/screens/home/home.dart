import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  final ScrollController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            floating: true,
            snap: true,
            surfaceTintColor: Colors.transparent,
            title: const Row(
              children: [
                const Text(
                  " | Home",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      isIos: true,
                      child: const SettingsPage(),
                    ),
                  );
                },
                icon: const Icon(
                  HugeIcons.strokeRoundedSettings03,
                ),
              ),
            ],
          ),
        ];
      },
      body: Container(
        alignment: Alignment.center, // Center the text
        child: const Text(
          'Home', // Display the title 'name'
          style: TextStyle(
            fontSize: 24, // Customize the text size
            fontWeight: FontWeight.bold, // Optional: make the text bold
          ),
        ),
      ),
    );
  }
}
