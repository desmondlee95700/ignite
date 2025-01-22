part of 'pip_bloc.dart';

sealed class PipEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class RunPiP extends PipEvent {
  RunPiP({
    required this.videoObj,
  });

  final Video? videoObj;
}

final class ClosePip extends PipEvent {
  ClosePip();
}
