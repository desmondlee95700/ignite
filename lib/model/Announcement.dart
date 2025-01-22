final class Announcement {
  Announcement({
    required this.title,
    required this.image,
  });

  String? title;
  String? image;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json["title"],
      image: json["image"],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "image": image,
    };
    return data;
  }
}
