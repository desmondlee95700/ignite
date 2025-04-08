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
    final postDateRaw = json['post_date'];
    DateTime? postDate;

    if (postDateRaw is Timestamp) {
      postDate = postDateRaw.toDate();
    } else if (postDateRaw is String) {
      postDate = DateTime.tryParse(postDateRaw);
    }

    return Announcement(
      title: json["title"],
      description: json["description"],
      image: json["image"],
      url: json["url"],
      post_date: postDate,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "image": image,
      "url": url,
      "post_date": post_date?.toIso8601String()
    };
    return data;
  }
}
