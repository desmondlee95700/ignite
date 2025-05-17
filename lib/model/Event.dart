import 'package:cloud_firestore/cloud_firestore.dart';

final class Event {
  Event({
    required this.title,
    required this.start_post_date,
    required this.end_post_date,
    required this.schedule_image,
    required this.image,
  });

  String? title;
  DateTime? start_post_date;
  DateTime? end_post_date;
  List<String>? schedule_image; // changed to list of strings
  String? image;

  factory Event.fromJson(Map<String, dynamic> json) {
    final startPostDateRaw = json['start_post_date'];
    DateTime? startPostDate;
    final endPostDateRaw = json['end_post_date'];
    DateTime? endPostDate;

    if (startPostDateRaw is Timestamp) {
      startPostDate = startPostDateRaw.toDate();
    } else if (startPostDateRaw is String) {
      startPostDate = DateTime.tryParse(startPostDateRaw);
    }

    if (endPostDateRaw is Timestamp) {
      endPostDate = endPostDateRaw.toDate();
    } else if (endPostDateRaw is String) {
      endPostDate = DateTime.tryParse(endPostDateRaw);
    }

    // Parse schedule_image as List<String> if possible
    List<String>? scheduleImageList;
    if (json['schedule_image'] is List) {
      scheduleImageList = List<String>.from(json['schedule_image']);
    } else if (json['schedule_image'] is String) {
      // fallback: if it’s a single string, wrap it in a list
      scheduleImageList = [json['schedule_image']];
    }

    return Event(
      title: json["title"],
      start_post_date: startPostDate,
      end_post_date: endPostDate,
      image: json["image"],
      schedule_image: scheduleImageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "start_post_date": start_post_date?.toIso8601String(),
      "end_post_date": end_post_date?.toIso8601String(),
      "image": image,
      "schedule_image": schedule_image,
    };
  }
}
