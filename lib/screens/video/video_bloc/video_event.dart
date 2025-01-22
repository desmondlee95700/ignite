part of 'video_bloc.dart';

sealed class VideoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FetchVideo extends VideoEvent {
  FetchVideo({
    this.nextKey,
    this.type,
    this.retrying,
  });

  final String? nextKey;
  final String? type;
  final bool? retrying;
}
