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
  String? schedule_image;
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

    return Event(
        title: json["title"],
        start_post_date: startPostDate,
        end_post_date: endPostDate,
        image: json["image"],
        schedule_image: json["schedule_image"]);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "start_post_date": start_post_date?.toIso8601String(),
      "end_post_date": end_post_date?.toIso8601String(),
      "image": image,
      "schedule_image": schedule_image
    };
    return data;
  }
}
