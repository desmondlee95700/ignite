import 'package:ignite/model/Post.dart';

class Video {
  Video({
    required this.ID,
    required this.post_date,
    required this.post_title,
    required this.web_url,
    required this.thumbnail,
    required this.video_id,
  });

  int ID;
  String post_date;
  String post_title;
  String web_url;
  String? thumbnail;
  String video_id;

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
        ID: json["ID"],
        post_date: json["post_date"],
        post_title: json["post_title"],
        web_url: json["web_url"],
        thumbnail: json["thumbnail"],
        video_id: json["video_id"]);
  }

  factory Video.fromPost(Post post) {
    return Video(
      ID: post.ID,
      post_date: post.post_date,
      post_title: post.post_title,
      web_url: post.web_url,
      thumbnail: post.thumbnail,
      video_id: post.video_id ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "ID": ID,
      "post_date": post_date,
      "post_title": post_title,
      "web_url": web_url,
      "thumbnail": thumbnail,
      "video_id": video_id
    };
    return data;
  }
}
