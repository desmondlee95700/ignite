part of 'musicitem_bloc.dart';

sealed class MusicItemEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FetchMusicItem extends MusicItemEvent {
  FetchMusicItem({
    this.retrying,
  });

  final bool? retrying;
}