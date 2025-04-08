part of 'appdata_bloc.dart';

enum AppDataStatus { initial, loading, success, failure }

final class AppDataState extends Equatable {
  const AppDataState({
    this.status = AppDataStatus.initial,
    this.announcements = const <Announcement>[],
    this.events = const <Event>[],
    this.errorMsg,
    this.retrying = false,
  });

  final AppDataStatus status;
  final List<Announcement> announcements;
  final List<Event> events;
  final String? errorMsg;
  final bool retrying;

  AppDataState copyWith({
    AppDataStatus? status,
    List<Announcement>? announcements,
    List<Event>? events,
    String? errorMsg,
    bool? retrying,
  }) {
    return AppDataState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      events: events ?? this.events,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''AppDataState { status: $status, announcements: ${announcements.length}, events: ${events.length} }''';
  }

  @override
  List<Object?> get props => [status, announcements, events, errorMsg, retrying];
}
