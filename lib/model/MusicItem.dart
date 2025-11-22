class MusicItem {
  MusicItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.youtubeUrl,
    this.spotifyUrl,
    required this.itemType,
    this.isNewRelease = false,
    this.createdAt,
  });

  int id;
  String title;
  String thumbnail;
  String? youtubeUrl;
  String? spotifyUrl;
  String itemType; // "song" or "video"
  bool isNewRelease;
  DateTime? createdAt;

  // Factory constructor from JSON (Supabase map)
  factory MusicItem.fromJson(Map<String, dynamic> json) {
    return MusicItem(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      youtubeUrl: json['youtube_url'] as String?,
      spotifyUrl: json['spotify_url'] as String?,
      itemType: json['item_type'] as String,
      isNewRelease: json['is_new_release'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Convert to JSON for insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'youtube_url': youtubeUrl,
      'spotify_url': spotifyUrl,
      'item_type': itemType,
      'is_new_release': isNewRelease,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
