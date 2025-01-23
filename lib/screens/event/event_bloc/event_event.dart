part of 'event_bloc.dart';

sealed class EventEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FetchEvent extends EventEvent {
  FetchEvent({
    this.retrying,
  });

  final bool? retrying;
}
