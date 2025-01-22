part of 'video_bloc.dart';

enum VideoStatus { initial, success, failure }

final class VideoState extends Equatable {
  const VideoState({
    this.status = VideoStatus.initial,
    this.videos = const <Video>[],
    this.hasReachedMax = false,
    this.nextKey,
    this.type,
    this.errorMsg,
    this.retrying = false,
  });

  final VideoStatus status;
  final List<Video> videos;
  final bool hasReachedMax;
  final String? nextKey;
  final String? type;
  final String? errorMsg;
  final bool retrying;

  VideoState copyWith({
    VideoStatus? status,
    List<Video>? videos,
    bool? hasReachedMax,
    String? nextKey,
    String? type,
    String? errorMsg,
    bool? retrying,
  }) {
    return VideoState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextKey: nextKey ?? this.nextKey,
      type: type ?? this.type,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''VideoState { status: $status,video: ${videos.length}''';
  }

  @override
  List<Object?> get props =>
      [status, videos, hasReachedMax, nextKey, type, errorMsg];
}
