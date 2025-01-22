import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ignite/model/Video.dart';
import 'package:stream_transform/stream_transform.dart';

part 'pip_event.dart';
part 'pip_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PipBloc extends Bloc<PipEvent, PipState> {
  PipBloc() : super(const PipState()) {
    on<RunPiP>(_onPipFetched, transformer: throttleDroppable(throttleDuration));

    on<ClosePip>(_onPipClosed,
        transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onPipFetched(RunPiP event, Emitter<PipState> emit) async {
    return emit(state.copyWith(
      video: event.videoObj,
      isPipActive: true,
    ));
  }

  Future<void> _onPipClosed(ClosePip event, Emitter<PipState> emit) async {
    return emit(state.copyWith(
      isPipActive: false,
    ));
  }
}
