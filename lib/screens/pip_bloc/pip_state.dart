part of 'pip_bloc.dart';

final class PipState extends Equatable {
  const PipState({
    this.video,
    this.isPipActive = false,
  });

  final Video? video;
  final bool isPipActive;

  PipState copyWith({
    Video? video,
    bool? isPipActive,
  }) {
    return PipState(
      video: video,
      isPipActive: isPipActive ?? this.isPipActive,
    );
  }

  @override
  String toString() {
    return '''PipState { status: $video, ''';
  }

  @override
  List<Object?> get props => [
        video,
        isPipActive,
      ];
}
