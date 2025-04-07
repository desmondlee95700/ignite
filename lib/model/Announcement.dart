import 'package:cloud_firestore/cloud_firestore.dart';

final class Announcement {
  Announcement({
    required this.title,
    required this.description,
    required this.image,
    required this.url,
    required this.post_date,
  });

  String? title;
  String? description;
  String? image;
  String? url;
  DateTime? post_date; // Change to DateTime

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json["title"],
      description: json["description"],
      image: json["image"],
      url : json["url"],
      post_date: (json["post_date"] as Timestamp?)?.toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "image": image,
      "url" : url,
      "post_date": post_date
    };
    return data;
  }
}
