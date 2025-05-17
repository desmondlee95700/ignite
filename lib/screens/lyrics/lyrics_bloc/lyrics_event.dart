part of 'lyrics_bloc.dart';

sealed class LyricsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FetchLyrics extends LyricsEvent {
  FetchLyrics({
    this.retrying,
  });

  final bool? retrying;
}
