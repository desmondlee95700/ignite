import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Announcement.dart';

class AnnouncementPeekView extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementPeekView({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: 20, vertical: screenHeight * 0.1),
      child: Container(
        width: screenWidth - 40, // screen width
        decoration: BoxDecoration(
          color: darkThemeColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60, // Header container
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 20.0,
                      backgroundImage:
                          AssetImage("assets/images/ignite_icon.jpg"),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          announcement.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: CachedNetworkImage(
                imageUrl: announcement.image!,
                errorWidget: (context, url, error) => Image.asset(
                  "assets/images/ignite_icon.png",
                  fit: BoxFit.cover,
                ),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              // height: 80,
              decoration: const BoxDecoration(
                color: darkThemeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    announcement.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Manrope',
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
