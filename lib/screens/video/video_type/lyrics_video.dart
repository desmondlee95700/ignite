import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Video.dart';
import 'package:ignite/screens/video/video_bloc/video_bloc.dart';
import 'package:ignite/screens/video/video_item/video_item.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

class LyricsVideoPage extends StatefulWidget {
  final ScrollController controller;

  const LyricsVideoPage({super.key, required this.controller});

  @override
  _LyricsVideoPageState createState() => _LyricsVideoPageState();
}

class _LyricsVideoPageState extends State<LyricsVideoPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final VideoBloc videoBloc = VideoBloc(httpClient: http.Client());
  String? nextKey;

  @override
  void initState() {
    super.initState();
    videoBloc.add(FetchVideo(type: "lyricvideo"));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedCircleArrowLeft02,
              size: 25, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Row(
          children: [
            Text(
              " | Lyrics Video",
              style: TextStyle(
                color: kPrimaryColor,
                fontFamily: 'Manrope',
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: BlocProvider(
        create: (_) => videoBloc,
        child: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state.status == VideoStatus.initial) {
              return GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    crossAxisCount:
                        MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                    childAspectRatio: 0.75,
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                    left: 5,
                    right: 5,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey,
                        ),
                      ),
                    );
                  });
            } else {
              List<Video> videos = state.videos;

              String? errorMsg = state.errorMsg;
              nextKey = state.nextKey;

              return RefreshIndicator.adaptive(
                color: kPrimaryColor,
                onRefresh: () async {
                  videoBloc.add(FetchVideo(retrying: true, type: "lyrics"));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                    left: 5,
                    right: 5,
                  ),
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          crossAxisCount:
                              MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final Video videoData = videos[index];
                          return VideoItem(
                            videoData: videoData,
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: state.hasReachedMax
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  errorMsg ?? "You have reached the bottom",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ))
                            : VisibilityDetector(
                                key: const Key('load-more'),
                                onVisibilityChanged: (visibilityInfo) {
                                  var visiblePercentage =
                                      visibilityInfo.visibleFraction * 100;
                                  if (visiblePercentage > 95) {
                                    videoBloc.add(FetchVideo(
                                      //nextKey: nextKey,
                                      nextKey: null,
                                      type: "lyrics",
                                      retrying: false,
                                    ));
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ), // Loading indicator
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
