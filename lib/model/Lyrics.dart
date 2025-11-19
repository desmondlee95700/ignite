final class Lyrics {
  Lyrics({
    required this.id,
    required this.image_url,
    required this.pdf_url,
    required this.title,
  });

  int id;
  String image_url;
  String pdf_url;
  String title;

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      id: json["id"],
      image_url: json["image_url"],
      pdf_url: json["pdf_url"],
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "id": id,
      "image_url": image_url,
      "pdf_url": pdf_url,
      "title": title
    };
    return data;
  }
}
