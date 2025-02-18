import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/event/calendar_page.dart';
import 'package:page_transition/page_transition.dart';

class ThemePage extends StatefulWidget {
  final ScrollController controller;

  const ThemePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final List<Map<String, String>> themes = [
    {
      'title': 'Ignite Chapel Worship',
      'image': 'assets/images/ignite_icon.jpg'
    },
    {'title': 'Kingdom', 'image': 'assets/images/ignite_icon.jpg'},
    {'title': 'Praise Party', 'image': 'assets/images/ignite_icon.jpg'},
  ];

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  " | Ignite Themes",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        duration: const Duration(milliseconds: 600),
                        reverseDuration: const Duration(milliseconds: 600),
                        isIos: true,
                        child: const CalendarPage(),
                      ),
                    );
                  },
                  child: const Icon(HugeIcons.strokeRoundedCalendar01,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Handle theme selection
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        themes[index]['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          themes[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
