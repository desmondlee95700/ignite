final class Announcement {
  Announcement({
    required this.title,
    required this.description,
    required this.image,
  });

  String? title;
  String? description;
  String? image;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json["title"],
      description: json["description"],
      image: json["image"],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "description": description,
      "image": image,
    };
    return data;
  }
}
