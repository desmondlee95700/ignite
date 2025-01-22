import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/screens/annoucement/annoucement.dart';
import 'package:ignite/screens/event/event.dart';
import 'package:ignite/screens/home/home.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:ignite/screens/video/video.dart';

class AppBody extends StatefulWidget {
  const AppBody({
    super.key,
  });

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  int _currentPage = 0;
  final _pageController = PageController(initialPage: 0);

  // List<Widget> tabPages = [
  //   const HomePage(),
  //   const ExplorePage(),
  //   const ArticlesPage(),
  //   const ReelsPage(),
  //   const PodcastPage(),
  // ];

  // Map to store scroll controllers for each page
  final Map<int, ScrollController> _scrollControllers = {
    0: ScrollController(),
    1: ScrollController(),
    2: ScrollController(),
    3: ScrollController(),
    4: ScrollController(),
  };

  // Variable to track the last tap time for navigation items
  DateTime? _lastTapTime;

  List<Widget> tabPages(BuildContext context) => [
        HomePage(controller: _scrollControllers[0]!),
        AnnoucementPage(controller: _scrollControllers[1]!),
        DiscoverPage(controller: _scrollControllers[2]!),
        VideoPage(controller: _scrollControllers[3]!),
        const SettingsPage(),
      ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //showExit(context);
        return false;
      },
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: CrystalNavigationBar(
          currentIndex: _currentPage,
          onTap: (index) {
            // setState(() => _currentPage = index);
            // _pageController.jumpToPage(index);
            final now = DateTime.now();

            if (_currentPage == index) {
              // Check if this is a double-tap
              if (_lastTapTime == null ||
                  now.difference(_lastTapTime!) >
                      const Duration(milliseconds: 300)) {
                // Record the tap time
                _lastTapTime = now;
              } else {
                // Perform the scroll-to-top action on double-tap
                _scrollControllers[index]?.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                _lastTapTime = null; // Reset the last tap time
              }
            } else {
              // Navigate to a different page
              setState(() => _currentPage = index);
              _pageController.jumpToPage(index);
            }
          },
          indicatorColor: Colors.white,
          backgroundColor: Colors.black,
          items: [
            CrystalNavigationBarItem(
              icon: HugeIcons.strokeRoundedHome01,
              unselectedIcon: HugeIcons.strokeRoundedHome01,
              selectedColor: Colors.red,
              unselectedColor: Colors.white,
            ),
            CrystalNavigationBarItem(
              icon: HugeIcons.strokeRoundedMegaphone02,
              unselectedIcon: HugeIcons.strokeRoundedMegaphone02,
              selectedColor: Colors.red,
              unselectedColor: Colors.white,
            ),
            CrystalNavigationBarItem(
              icon: HugeIcons.strokeRoundedCalendar03,
              unselectedIcon: HugeIcons.strokeRoundedCalendar03,
              selectedColor: Colors.red,
              unselectedColor: Colors.white,
            ),
            CrystalNavigationBarItem(
              icon: HugeIcons.strokeRoundedPlayList,
              unselectedIcon: HugeIcons.strokeRoundedPlayList,
              selectedColor: Colors.red,
              unselectedColor: Colors.white,
            ),
            CrystalNavigationBarItem(
              icon: HugeIcons.strokeRoundedSettings03,
              unselectedIcon: HugeIcons.strokeRoundedSettings03,
              selectedColor: Colors.red,
              unselectedColor: Colors.white,
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabPages(context),
        ),
      ),
    );
  }
}
