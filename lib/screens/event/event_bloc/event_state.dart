part of 'event_bloc.dart';

enum EventStatus { initial, success, failure }

final class EventState extends Equatable {
  const EventState({
    this.status = EventStatus.initial,
    this.events = const <Event>[],
    this.hasReachedMax = false,
    this.title,
    this.errorMsg,
    this.retrying = false,
  });

  final EventStatus status;
  final List<Event> events;
  final bool hasReachedMax;
  final String? title;
  final String? errorMsg;
  final bool retrying;

  EventState copyWith({
    EventStatus? status,
    List<Event>? events,
    bool? hasReachedMax,
    String? title,
    String? errorMsg,
    bool? retrying,
  }) {
    return EventState(
      status: status ?? this.status,
      events: events ?? this.events,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      title: title ?? this.title,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''EventState { status: $status, event: ${events.length}''';
  }

  @override
  List<Object?> get props =>
      [status, events, hasReachedMax, title, errorMsg];
}
