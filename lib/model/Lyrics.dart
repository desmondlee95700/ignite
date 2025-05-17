final class Lyrics {
  Lyrics({
    required this.ID,
    required this.image_url,
    required this.pdf_url,
    required this.title,
  });

  int ID;
  String image_url;
  String pdf_url;
  String title;

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      ID: json["ID"],
      image_url: json["image_url"],
      pdf_url: json["pdf_url"],
      title: json["title"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "ID": ID,
      "image_url": image_url,
      "pdf_url": pdf_url,
      "title": title
    };
    return data;
  }
}
