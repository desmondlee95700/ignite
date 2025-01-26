import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/datetime_helper.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_details.dart';
import 'package:page_transition/page_transition.dart';

class EventCalendarCard extends StatelessWidget {
  final Event events;

  const EventCalendarCard({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: Card(
        color: Colors.black.withOpacity(0.1),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                events.image!,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Ignite ${getYearFromDateString(events.post_date.toString()).toString()}",
                      style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "Manrope",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  Text(events.title!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Manrope",
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(HugeIcons.strokeRoundedClock01,
                          size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(events.time!,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: "Manrope",
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
