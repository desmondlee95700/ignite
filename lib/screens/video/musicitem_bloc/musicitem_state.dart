part of 'musicitem_bloc.dart';

enum MusicItemStatus { initial, success, failure }

final class MusicItemState extends Equatable {
  const MusicItemState({
    this.status = MusicItemStatus.initial,
    this.musicItems = const <MusicItem>[],
    this.hasReachedMax = false,
    this.errorMsg,
    this.retrying = false,
  });

  final MusicItemStatus status;
  final List<MusicItem> musicItems;
  final bool hasReachedMax;
  final String? errorMsg;
  final bool retrying;

  // Computed getters for filtering
  List<MusicItem> get musicVideos =>
      musicItems.where((item) => item.itemType == "video").toList();

  List<MusicItem> get songs =>
      musicItems.where((item) => item.itemType == "song").toList();

  MusicItemState copyWith({
    MusicItemStatus? status,
    List<MusicItem>? musicItems,
    bool? hasReachedMax,
    String? errorMsg,
    bool? retrying,
  }) {
    return MusicItemState(
      status: status ?? this.status,
      musicItems: musicItems ?? this.musicItems,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''MusicState { status: $status, musicItems: ${musicItems.length}, videos: ${musicVideos.length}, songs: ${songs.length} }''';
  }

  @override
  List<Object?> get props =>
      [status, musicItems, hasReachedMax, errorMsg, retrying];
}
