import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:share_plus/share_plus.dart';

class AnnouncementPeekView extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementPeekView({super.key, required this.announcement});

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
            SizedBox(
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
                            fontSize: 14,
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
            Stack(
              children: [
                // The image in the background
                SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: announcement.image!,
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/ignite_icon.jpg",
                      fit: BoxFit.cover,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                // The share icon overlaid on the image
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () async {
                      await Share.share(
                          '${announcement.title}\n\n${announcement.url}');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                            0.5), // Semi-transparent white background
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
                      ),
                      padding: const EdgeInsets.all(
                          6), // Add some padding around the icon
                      child: const Icon(
                        HugeIcons.strokeRoundedShare01,
                        color: Colors.black, // Use black for better contrast
                        size: 30, // Adjust the size of the icon as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              //height: 80,
              decoration: const BoxDecoration(
                color: darkThemeColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    announcement.description!,
                    maxLines: 3,
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
