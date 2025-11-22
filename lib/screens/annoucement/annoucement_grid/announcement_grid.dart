import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/screens/annoucement/peek_view/peekview_manager.dart';
import 'package:ignite/screens/video/video_item/video_single.dart';
import 'package:ignite/screens/webview/webview.dart';
import 'package:page_transition/page_transition.dart';

class ExploreGridItem extends StatelessWidget {
  final Announcement announcement;

  const ExploreGridItem({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        announcement.type == "video_link"
            ? Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                  isIos: true,
                  child: WebViewPage(
                    url: announcement.url.toString(),
                  ),
                ),
              )
            : announcement.type == "youtube"
                ? Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      isIos: true,
                      opaque: true,
                      child: VideoSinglePage(
                        videoURL: announcement.url.toString(),
                        title: announcement.title.toString(),
                        date: announcement.post_date!,
                        thumbnail: announcement.image.toString(),
                      ),
                    ),
                  )
                : Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      isIos: true,
                      child: WebViewPage(
                        url: announcement.url.toString(),
                      ),
                    ),
                  );
      },
      onLongPress: () {
        HapticFeedback.vibrate();
        final peekViewManager = PeekViewManager(announcement: announcement);
        peekViewManager.showAnnouncementPeekView(context,
            announcement: announcement);
      },
      onLongPressUp: () {
        final peekViewManager = PeekViewManager(announcement: announcement);
        peekViewManager.showFullView(context);
      },
      child: Stack(
        children: [
          announcement.image != null
              ? CachedNetworkImage(
                  imageUrl: announcement.image!,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    );
                  },
                  placeholder: (context, url) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/ignite_icon.jpg"),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  padding: const EdgeInsets.all(4),
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
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
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    HugeIcons.strokeRoundedNews01,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      announcement.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: "Manrope",
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
