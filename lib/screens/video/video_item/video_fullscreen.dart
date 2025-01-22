import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/datetime_helper.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:ignite/model/Video.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:html/parser.dart' as html_parser;

class VideoFullscreenItem extends StatefulWidget {
  final Video videos;
  //final VoidCallback onNextPage;

  const VideoFullscreenItem({
    super.key,
    required this.videos,
  });

  @override
  _VideoFullscreenItemState createState() => _VideoFullscreenItemState();
}

class _VideoFullscreenItemState extends State<VideoFullscreenItem> {
  late YoutubePlayerController _youtubePlayerController;
  late TextEditingController _idController;

  late YoutubeMetaData _videoMetaData;

  bool _isPlayerReady = false;
  bool _isFullScreen = false;

  double _seekTo = 0.0;

  var unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeVideoPlayer();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _youtubePlayerController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    _idController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _initializeVideoPlayer() async {
    try {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: widget.videos.video_id,
        flags: YoutubePlayerFlags(
            mute: false,
            autoPlay: true,
            disableDragSeek: true,
            hideThumbnail: true,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: false,
            hideControls: _isFullScreen),
      )..addListener(listener);

      _idController = TextEditingController();
      _videoMetaData = const YoutubeMetaData();
    } catch (e, stackTrace) {
      print(stackTrace);
      print(e);
    }
  }

  void listener() {
    if (_isPlayerReady && mounted) {
      setState(() {
        _seekTo = _youtubePlayerController.value.position.inSeconds.toDouble();
        _videoMetaData = _youtubePlayerController.metadata;
        bool isFullscreen = _youtubePlayerController.value.isFullScreen;
        if (_isFullScreen != isFullscreen) {
          _isFullScreen = isFullscreen;
          //widget.onFullscreenChange(_isFullScreen);
        }
      });
    }
  }

  // void _handleVideoCompletion() {
  //   _youtubePlayerController
  //       .seekTo(const Duration(seconds: 0)); // Rewind the video
  //   _youtubePlayerController.pause(); // Pause the video
  //   widget.onNextPage();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedCircleArrowLeft02,
              size: 25, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
        },
        player: YoutubePlayer(
          key: ValueKey(_isFullScreen),
          width: MediaQuery.of(context).size.width,
          aspectRatio: _isFullScreen ? 16 / 9 : 1 / 3,
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
          thumbnail: widget.videos.thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: widget.videos.thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      "assets/images/ignite_icon.jpg",
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset("assets/images/ignite_icon.jpg", fit: BoxFit.cover),
          onReady: () {
            _isPlayerReady = true;
          },
          // onEnded: (data) {
          //   _handleVideoCompletion();
          // },
        ),
        builder: (context, player) => GestureDetector(
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Center(
                  child: player,
                ),
                Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: getProportionateScreenHeight(35),
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unescape.convert(
                                    _youtubePlayerController.metadata.title),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: getProportionateScreenHeight(5)),
                              Text(
                                convertDateFormat(widget.videos.post_date),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                Positioned(
                  bottom: getProportionateScreenHeight(170),
                  right: getProportionateScreenWidth(15),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          await Share.share(
                              "${unescape.convert(widget.videos.post_title)}\n\n"
                              "${widget.videos.web_url}");
                        },
                        child: const Icon(
                          HugeIcons.strokeRoundedShare05,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String reformatDuration(Duration duration) {
    // Extract minutes and seconds from Duration
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String extractPlainText(String htmlContent) {
    final document = html_parser.parse(htmlContent);
    return document.body?.text ?? ""; // Extracts only the text content
  }
}
