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
  Timestamp? start_post_date;
  Timestamp? end_post_date;
  String? schedule_image;
  String? image;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json["title"],
        start_post_date: json["start_post_date"],
        end_post_date: json["end_post_date"],
        image: json["image"],
        schedule_image: json["schedule_image"]);
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "start_post_date": start_post_date,
      "end_post_date": end_post_date,
      "image": image,
      "schedule_image": schedule_image
    };
    return data;
  }
}
