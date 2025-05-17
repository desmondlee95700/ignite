part of 'lyrics_bloc.dart';

enum LyricsStatus { initial, success, failure }

final class LyricsState extends Equatable {
  const LyricsState({
    this.status = LyricsStatus.initial,
    this.lyrics = const <Lyrics>[],
    this.hasReachedMax = false,
    this.title,
    this.errorMsg,
    this.retrying = false,
  });

  final LyricsStatus status;
  final List<Lyrics> lyrics;
  final bool hasReachedMax;
  final String? title;
  final String? errorMsg;
  final bool retrying;

  LyricsState copyWith({
    LyricsStatus? status,
    List<Lyrics>? lyrics,
    bool? hasReachedMax,
    String? title,
    String? errorMsg,
    bool? retrying,
  }) {
    return LyricsState(
      status: status ?? this.status,
      lyrics: lyrics ?? this.lyrics,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''LyricsState { status: $status, annoucement: ${lyrics.length}''';
  }

  @override
  List<Object?> get props =>
      [status, lyrics, hasReachedMax, errorMsg];
}
