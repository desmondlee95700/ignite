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
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: Row(
            children: [
              // Image Section
              Container(
                width: 130,
                height: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: announcement.image != null
                    ? CachedNetworkImage(
                        imageUrl: announcement.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[900]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      )
                    : Container(color: Colors.grey[900]),
              ),
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Adjusted for space
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            announcement.description ??
                                announcement.type?.toUpperCase() ??
                                "",
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 11,
                              fontFamily: 'Manrope',
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFEF4444).withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(announcement.post_date),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const Spacer(),
                          Transform.rotate(
                              angle:
                                  -0.7, // Slight tilt like design if needed, or 0
                              child: const Icon(
                                HugeIcons.strokeRoundedArrowRight01,
                                color: Color(0xFFEF4444), // Red 500
                                size: 18,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    // Manual formatting to match "MMM D, YYYY" if intl not available, or simple YYYY-MM-DD
    // Using simple approach without heavy intl for now unless available
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
