import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/datetime_helper.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_details.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class EventCalendarCard extends StatelessWidget {
  final Event events;
  final DateTime selectedDay;

  const EventCalendarCard(
      {Key? key, required this.events, required this.selectedDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _getEventTimeBasedOnSelectedDate(
        Timestamp? startDate, Timestamp? endDate, DateTime? selectedDay) {
      if (startDate == null || selectedDay == null)
        return "No start date available";

      // Convert both start and end timestamps to DateTime objects
      DateTime startDateTime = startDate.toDate().toLocal();
      DateTime? endDateTime = endDate?.toDate().toLocal();

      // Normalize the selected date to just the year, month, and day (ignoring time)
      DateTime normalizedSelectedDate =
          DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

      // Normalize the event start date and end date to ignore time part
      DateTime normalizedStartDateTime =
          DateTime(startDateTime.year, startDateTime.month, startDateTime.day);
      DateTime? normalizedEndDateTime = endDateTime != null
          ? DateTime(endDateTime.year, endDateTime.month, endDateTime.day)
          : null;

      // If the selected date matches the normalized start date
      if (normalizedSelectedDate.isAtSameMomentAs(normalizedStartDateTime)) {
        return "Start Time: ${DateFormat('h:mm a').format(startDateTime)}";
      }

      // If the selected date matches the normalized end date
      if (normalizedEndDateTime != null &&
          normalizedSelectedDate.isAtSameMomentAs(normalizedEndDateTime)) {
        return "Start Time: ${DateFormat('h:mm a').format(endDateTime!)}";
      }

      // If the selected date doesn't match the start or end date, return a default message
      return "No event on this date";
    }

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
                      "Ignite ${getYearFromDateString(DateFormat('yyyy-MM-dd').format(
                        events.start_post_date!.toDate().toLocal(),
                      )).toString()}",
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
                      Text(
                        _getEventTimeBasedOnSelectedDate(
                          events.start_post_date,
                          events.end_post_date,
                          selectedDay, // The selected date from the calendar
                        ),
                        style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: "Manrope",
                            fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
