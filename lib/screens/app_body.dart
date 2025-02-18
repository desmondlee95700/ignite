import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:flutter_in_app_pip/pip_widget.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Video.dart';
import 'package:ignite/screens/annoucement/annoucement.dart';
import 'package:ignite/screens/home/home.dart';
import 'package:ignite/screens/pip_bloc/pip_bloc.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:ignite/screens/theme/theme.dart';
import 'package:ignite/screens/video/video.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
        ThemePage(controller: _scrollControllers[2]!),
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

  void pipPlayer(Video video) {
    late YoutubePlayerController _youtubePlayerController;

    try {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: video.video_id,
        flags: const YoutubePlayerFlags(
            mute: false,
            autoPlay: true,
            disableDragSeek: true,
            hideThumbnail: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: false),
      );
    } catch (e, stackTrace) {
      print(stackTrace);
      print(e);
    }

    PictureInPicture.updatePiPParams(
      pipParams: PiPParams(
        pipWindowHeight: 144,
        pipWindowWidth: 256,
        bottomSpace: 64,
        leftSpace: 64,
        rightSpace: 64,
        topSpace: 64,
        maxSize: Size(256, 144),
        minSize: Size(144, 108),
        movable: true,
        resizable: false,
        initialCorner: PIPViewCorner.bottomRight,
      ),
    );

    PictureInPicture.startPiP(
      pipWidget: PiPWidget(
        onPiPClose: () {
          // context.read<PipBloc>().add(ClosePip());
          // PictureInPicture.stopPiP();
          print("Logged pip closed");
        },
        elevation: 0,
        pipBorderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  child: YoutubePlayer(
                    controller: _youtubePlayerController,
                    showVideoProgressIndicator: true,
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: GestureDetector(
                    onTap: () {
                      context.read<PipBloc>().add(ClosePip());
                      PictureInPicture.stopPiP();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(5.0),
                      child: const Icon(Icons.close, color: Colors.black, size : 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //showExit(context);
        return false;
      },
      child: BlocListener<PipBloc, PipState>(
        listener: (context, state) {
          if (state.video != null) {
            print("Logged is here not null");
            pipPlayer(state.video!);
          } else {
            print("Logged is here");
          }
        },
        child: Scaffold(
          extendBody: true,
          bottomNavigationBar: FlashyTabBar(
            animationCurve: Curves.linear,
            selectedIndex: _currentPage,
            showElevation: false,
            backgroundColor: darkThemeColor,
            onItemSelected: (index) {
              final now = DateTime.now();
              if (_currentPage == index) {
                if (_lastTapTime == null ||
                    now.difference(_lastTapTime!) >
                        const Duration(milliseconds: 300)) {
                  _lastTapTime = now;
                } else {
                  _scrollControllers[index]?.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  _lastTapTime = null;
                }
              } else {
                setState(() => _currentPage = index);
                _pageController.jumpToPage(index);
              }
            },
            items: [
              FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedFire),
                  title: const Text('Ignite'),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey),
              FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedMegaphone02),
                  title: const Text('News'),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey),
              FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedAlbum01),
                  title: const Text('Theme'),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey),
              FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedPlayList),
                  title: const Text('Video'),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey),
              FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedSettings03),
                  title: const Text('Setting'),
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey),
            ],
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: tabPages(context),
          ),
        ),
      ),
    );
  }
}
