import 'package:cloud_firestore/cloud_firestore.dart';

final class Event {
  Event({
    this.id,
    required this.title,
    required this.start_post_date,
    required this.end_post_date,
    required this.schedule_image,
    required this.image,
    this.description,
    this.location,
    this.price,
    this.payment_url,
    this.registration_url,
  });

  int? id;
  String? title;
  DateTime? start_post_date;
  DateTime? end_post_date;
  List<String>? schedule_image; // changed to list of strings
  String? image;
  String? description;
  String? location;
  double? price;
  String? payment_url;
  String? registration_url;

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
      id: json["id"],
      title: json["title"],
      start_post_date: startPostDate,
      end_post_date: endPostDate,
      image: json["image"],
      schedule_image: scheduleImageList,
      description: json["description"],
      location: json["location"],
      price: (json["price"] as num?)?.toDouble(),
      payment_url: json["payment_url"],
      registration_url: json["registration_url"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "start_post_date": start_post_date?.toIso8601String(),
      "end_post_date": end_post_date?.toIso8601String(),
      "image": image,
      "schedule_image": schedule_image,
      "description": description,
      "location": location,
      "price": price,
      "payment_url": payment_url,
      "registration_url": registration_url,
    };
  }
}
