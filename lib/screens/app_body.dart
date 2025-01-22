import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
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
import 'package:ignite/screens/event/event.dart';
import 'package:ignite/screens/home/home.dart';
import 'package:ignite/screens/pip_bloc/pip_bloc.dart';
import 'package:ignite/screens/settings/settings.dart';
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

  void pipPlayer(Video video) {
    late YoutubePlayerController _youtubePlayerController;

    try {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: video.video_id,
        flags: const YoutubePlayerFlags(
            mute: false,
            autoPlay: true,
            disableDragSeek: true,
            hideThumbnail: true,
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
      pipParams: const PiPParams(
        pipWindowHeight: 144,
        pipWindowWidth: 256,
        bottomSpace: 64,
        leftSpace: 12,
        rightSpace: 12,
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
          context.read<PipBloc>().add(ClosePip());
        },
        elevation: 0, //Optional
        pipBorderRadius: 10,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                width: MediaQuery.of(context).size.width,
                aspectRatio: 1 / 3,
                controller: _youtubePlayerController,
                showVideoProgressIndicator: true,
                actionsPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                progressIndicatorColor: kPrimaryColor,
                progressColors: const ProgressBarColors(
                    playedColor: kPrimaryColor,
                    backgroundColor: Colors.black,
                    bufferedColor: darkThemeColor),
                bottomActions: const [
                  SizedBox(width: 2.0),
                  CurrentPosition(),
                  SizedBox(width: 5.0),
                  ProgressBar(
                    isExpanded: true,
                    colors: ProgressBarColors(
                      playedColor: kPrimaryColor,
                      handleColor: Colors.white,
                    ),
                  ),
                  RemainingDuration(),
                  PlaybackSpeedButton(),
                  //FullScreenButton(),
                ],
                thumbnail: video.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: video.thumbnail!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Image.asset(
                            "assets/images/ignite_icon.jpg",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset("assets/images/ignite_icon.jpg",
                        fit: BoxFit.cover),
                onReady: () {},
              ),
              builder: (context, player) => Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: player,
                ),
              ),
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
            pipPlayer(state.video!);
          }
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
      ),
    );
  }
}
