final class Event {
  Event({
    required this.title,
    required this.post_date,
    required this.time,
    required this.image,
  });

  String? title;
  String? post_date;
  String? time;
  String? image;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json["title"],
      post_date: json["post_date"],
      time : json["time"],
      image: json["image"],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "title": title,
      "post_date": post_date,
      "time": time,
      "image": image,
    };
    return data;
  }
}
