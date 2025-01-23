import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ignite/functions/datetime_helper.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_details.dart';
import 'package:page_transition/page_transition.dart';

class HomeEventItem extends StatelessWidget {
  const HomeEventItem({
    super.key,
    required this.events,
  });

  final Event events;

  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 600),
            reverseDuration: const Duration(milliseconds: 600),
            isIos: true,
            child: EventDetailsPage(events: events),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Stack for Image and Date Circle
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: events.image != null
                      ? CachedNetworkImage(
                          imageUrl: events.image!,
                          imageBuilder: (context, imageProvider) => Container(
                            height: 200,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) {
                            return Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/ignite_icon.jpg",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage(
                                "assets/images/ignite_icon.jpg",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                // Date Circle
                Positioned(
                  bottom: -25, // Moves the circle down outside the image
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getDay(events.post_date.toString()), // Day
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Manrope',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          getMonthShort(events.post_date
                              .toString()), // Month abbreviation
                          style: const TextStyle(
                            fontSize: 8,
                            fontFamily: 'Manrope',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Space for the date circle
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                unescape.convert(events.title!),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "${events.time}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Manrope',
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
