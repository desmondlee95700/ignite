import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/screens/annoucement/peek_view/announcement_peek_view.dart';

class PeekViewManager {
  OverlayEntry? _peekOverlayEntry;
  final Announcement announcement;

  PeekViewManager({required this.announcement});

  void showAnnouncementPeekView(BuildContext context, {required Announcement announcement}) {
    _peekOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            onTap: removePeekView,
            child: Stack(
              children: <Widget>[
                BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5, sigmaY: 5), // blurred background
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.6), // Dimmed background color
                  ),
                ),
                AnnouncementPeekView(
                  announcement: announcement,
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_peekOverlayEntry!);
  }

  void removePeekView() {
    _peekOverlayEntry?.remove();
    _peekOverlayEntry = null;
  }

  void showFullView(BuildContext context) {
    _peekOverlayEntry?.remove();
    _peekOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 50,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: removePeekView,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_peekOverlayEntry!);
  }
}
