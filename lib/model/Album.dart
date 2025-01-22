import 'package:ignite/model/Post.dart';

class Album {
  Album({
    required this.post_title,
    required this.thumbnail,
  });

  String post_title;

  String? thumbnail;

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      post_title: json["post_title"],
      thumbnail: json["thumbnail"],
    );
  }

  factory Album.fromPost(Post post) {
    return Album(
      post_title: post.post_title,
      thumbnail: post.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "post_title": post_title,
      "thumbnail": thumbnail,
    };
    return data;
  }
}
