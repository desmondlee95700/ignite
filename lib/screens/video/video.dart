import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Album.dart';
import 'package:ignite/screens/event/calendar_page.dart';
import 'package:ignite/screens/video/video_type/conference_video.dart';
import 'package:ignite/screens/video/video_type/lyrics_video.dart';
import 'package:ignite/screens/video/video_type/music_video.dart';
import 'package:page_transition/page_transition.dart';

class VideoPage extends StatefulWidget {
  final ScrollController controller;

  const VideoPage({Key? key, required this.controller}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final List<Album> musicVideos = [
    Album(
        post_title: 'Music Video',
        thumbnail: 'https://i.ytimg.com/vi/AzSvIR2gsdg/hqdefault.jpg'),
    Album(
        post_title: 'Conference Highlight',
        thumbnail: 'https://i.ytimg.com/vi/h1obdF56-1k/hqdefault.jpg'),
    Album(
        post_title: 'Lyrics Video',
        thumbnail: 'https://i.ytimg.com/vi/uhsda41UnJI/hqdefault.jpg'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  " | Videos",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       PageTransition(
                //         type: PageTransitionType.rightToLeft,
                //         duration: const Duration(milliseconds: 600),
                //         reverseDuration: const Duration(milliseconds: 600),
                //         isIos: true,
                //         child: const CalendarPage(),
                //       ),
                //     );
                //   },
                //   child: const Icon(HugeIcons.strokeRoundedCalendar01,
                //       color: Colors.white),
                // ),
              ],
            ),
          ),
        ];
      },
      body: ListView.builder(
        itemCount: musicVideos.length,
        itemBuilder: (context, index) {
          final album = musicVideos[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the appropriate page based on the album
              if (album.post_title == 'Music Video') {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    isIos: true,
                    child: MusicVideoPage(
                      controller: widget.controller,
                    ),
                  ),
                );
              } else if (album.post_title == 'Conference Highlight') {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    isIos: true,
                    child: ConferenceVideoPage(
                      controller: widget.controller,
                    ),
                  ),
                );
              } else if (album.post_title == 'Lyrics Video') {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    isIos: true,
                    child: LyricsVideoPage(
                      controller: widget.controller,
                    ),
                  ),
                );
              }
            },
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Image background
                      CachedNetworkImage(
                        imageUrl: album.thumbnail!,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Container(
                            color: Colors.grey,
                            height: 200.0,
                            width: double.infinity,
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey,
                            height: 200.0,
                            width: double.infinity,
                            child: const Icon(
                              Icons.error,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      // Title overlay
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          album.post_title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
