import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Video.dart';
import 'package:ignite/screens/pip_bloc/pip_bloc.dart';
import 'package:ignite/screens/video/video_item/video_fullscreen.dart';
import 'package:page_transition/page_transition.dart';

class VideoItem extends StatelessWidget {
  final Video videoData;

  const VideoItem({super.key, required this.videoData});

  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();

    return InkWell(
      onTap: () async {
        if (context.read<PipBloc>().state.isPipActive) {       
          context.read<PipBloc>().add(ClosePip());
          PictureInPicture.stopPiP();
        }
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 300),
            isIos: true,
            child: VideoFullscreenItem(videos: videoData),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          videoData.thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: videoData.thumbnail!,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    );
                  },
                  placeholder: (context, url) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/ignite_icon.jpg"),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/ignite_icon.jpg"),
                    ),
                  ),
                ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 35,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: const Row(
                children: [
                  const Icon(
                    HugeIcons.strokeRoundedPlay,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 50,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black87,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Text(
              unescape.convert(videoData.post_title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Manrope',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
