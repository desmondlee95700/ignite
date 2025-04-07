import 'package:cloud_firestore/cloud_firestore.dart';

final class Announcement {
  Announcement({
    required this.title,
    required this.description,
    required this.image,
    required this.post_date,
  });

  String? title;
  String? description;
  String? image;
  Timestamp? post_date;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json["title"],
      description: json["description"],
      image: json["image"],
      post_date: json["post_date"]
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "image": image,
      "post_date" : post_date
    };
    return data;
  }
}
