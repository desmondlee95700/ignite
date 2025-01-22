class Post {
  Post(
      {required this.ID,
      required this.post_date,
      required this.post_title,
      required this.web_url,
      required this.thumbnail,
      this.video_id});

  int ID;
  String post_date;
  String post_title;
  String web_url;
  String? thumbnail;
  String? video_id;
  String? podcastLength;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      ID: json["ID"],
      post_date: json["post_date"],
      post_title: json["post_title"],
      web_url: json["web_url"],
      thumbnail: json["thumbnail"],
      video_id: json["video_id"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "ID": ID,
      "post_date": post_date,
      "post_title": post_title,
      "web_url": web_url,
      "thumbnail": thumbnail,
      "video_id": video_id,
    };
    return data;
  }
}
