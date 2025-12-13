import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:flutter_in_app_pip/pip_params.dart';
import 'package:flutter_in_app_pip/pip_view_corner.dart';
import 'package:flutter_in_app_pip/pip_widget.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/exit_app.dart';
import 'package:ignite/model/Video.dart';
import 'package:ignite/screens/annoucement/annoucement.dart';
import 'package:ignite/screens/home/home.dart';
import 'package:ignite/screens/lyrics/lyrics_page.dart';
import 'package:ignite/screens/pip_bloc/pip_bloc.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:ignite/screens/video/musicitem_bloc/musicitem_bloc.dart';
import 'package:ignite/screens/video/video.dart';
import 'package:ignite/screens/event/home_event.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
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
        LyricsPage(controller: _scrollControllers[2]!),
        MusicVideosPage(controller: _scrollControllers[3]!),
        MusicVideosPage(controller: _scrollControllers[3]!),
        EventsPage(controller: _scrollControllers[4]!),
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

  void pipPlayer(BuildContext context, Video video) {
    late YoutubePlayerController youtubePlayerController;

    try {
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: video.video_id,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: false,
          disableDragSeek: true,
          hideThumbnail: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
        ),
      );
    } catch (e, stackTrace) {
      print(stackTrace);
      print(e);
      return;
    }

    PictureInPicture.updatePiPParams(
      pipParams: const PiPParams(
        pipWindowHeight: 120,
        pipWindowWidth: 250,
        bottomSpace: 64,
        leftSpace: 12,
        rightSpace: 12,
        topSpace: 64,
        movable: true,
        resizable: false,
        initialCorner: PIPViewCorner.bottomRight,
      ),
    );

    PictureInPicture.startPiP(
      pipWidget: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => PiPWidget(
              onPiPClose: () {
                context.read<PipBloc>().add(ClosePip());
                PictureInPicture.stopPiP();
              },
              elevation: 0,
              pipBorderRadius: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        child: YoutubePlayer(
                          controller: youtubePlayerController,
                          showVideoProgressIndicator: true,
                          actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                          ],
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
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showExit(context);
        return false;
      },
      child: BlocListener<PipBloc, PipState>(
        listener: (context, state) {
          if (state.video != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration.zero, () {
                pipPlayer(context, state.video!);
              });
            });
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: darkThemeColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            extendBody: true,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.black,
                elevation: 0,
                selectedItemColor: kPrimaryColor, // Updated to primary color
                unselectedItemColor: Colors.grey[800],
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
                currentIndex: _currentPage,
                onTap: (index) {
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
                items: const [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(HugeIcons.strokeRoundedFire),
                    ),
                    label: 'IGNITE',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(HugeIcons.strokeRoundedMegaphone02),
                    ),
                    label: 'NEWS',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(HugeIcons.strokeRoundedFileMusic),
                    ),
                    label: 'LYRICS',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(HugeIcons.strokeRoundedMusicNote02),
                    ),
                    label: 'LISTEN',
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Icon(HugeIcons.strokeRoundedCalendar03),
                    ),
                    label: 'EVENTS',
                  ),
                ],
              ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomePage(
                    key: const PageStorageKey('homePage'),
                    controller: _scrollControllers[0]!),
                AnnoucementPage(
                    key: const PageStorageKey('announcementPage'),
                    controller: _scrollControllers[1]!),
                LyricsPage(
                    key: const PageStorageKey('lyricsPage'),
                    controller: _scrollControllers[2]!),
                BlocProvider(
                  create: (context) => MusicItemBloc(httpClient: http.Client())
                    ..add(FetchMusicItem()),
                  child: MusicVideosPage(
                    key: const Key('videoPage'),
                    controller: _scrollControllers[3],
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      EventBloc(httpClient: http.Client())..add(FetchEvent()),
                  child: EventsPage(
                      key: const PageStorageKey('eventsPage'),
                      controller: _scrollControllers[4]!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
