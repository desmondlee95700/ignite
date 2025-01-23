import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_utils/background_event_wave.dart';
import 'package:ignite/screens/home/home_utils/background_wave.dart';

class SilverEventDetailsAppBar extends SliverPersistentHeaderDelegate {
  final Event events;
  SilverEventDetailsAppBar({Key? key, required this.events});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var unescape = HtmlUnescape();
    var adjustedShrinkOffset =
        shrinkOffset > minExtent ? minExtent : shrinkOffset;
    double offset = (minExtent - adjustedShrinkOffset) * 0.5;
    double topPadding = MediaQuery.of(context).padding.top + 10;

    return Stack(
      children: [
        Positioned.fill(
          child: BackgroundEventWave(
            height: 300 + topPadding,
            backgroundImage: events.image,
          ),
        ),
        Positioned(
          top: topPadding,
          left: (15),
          right: (15),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              children: [
                Container(
                  width: (40),
                  height: (40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  child: IconButton(
                    icon: const Icon(HugeIcons.strokeRoundedArrowLeft02,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
