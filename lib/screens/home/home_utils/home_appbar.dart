import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ignite/screens/home/home_utils/background_wave.dart';
import 'package:marquee/marquee.dart';

class SilverAppHomeBar extends SliverPersistentHeaderDelegate {
  SilverAppHomeBar({
    Key? key,
  });

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
          child: BackgroundWave(
            height: 300 + topPadding,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 4,
          child: AnimatedOpacity(
            opacity: adjustedShrinkOffset > 25 ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 15,
                right: 15,
              ),
              // child: Center(
              //   child: Text(
              //     "A movement to see generations encounter Jesus 🔥",
              //     overflow: TextOverflow.ellipsis,
              //     maxLines: 1,
              //     style: TextStyle(
              //       fontSize: 12.0,
              //       fontWeight: FontWeight.bold,
              //       fontFamily: 'Manrope',
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              child: SizedBox(
                height: 20, // or any appropriate height
                width:
                    MediaQuery.of(context).size.width - 20, // to avoid overflow
                child: Marquee(
                  text: '🔥 A movement to see generations encounter Jesus | 📲 Follow us @ignitefcc',
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                    color: Colors.white,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  blankSpace: 40.0,
                  velocity: 30.0,
                  pauseAfterRound: const Duration(seconds: 1),
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topPadding,
          left: (10),
          right: (10),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedOpacity(
                      opacity: adjustedShrinkOffset > 50 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const SizedBox()),
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
