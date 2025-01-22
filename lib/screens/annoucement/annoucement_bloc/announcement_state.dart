part of 'announcement_bloc.dart';

enum AnnouncementStatus { initial, success, failure }

final class AnnouncementState extends Equatable {
  const AnnouncementState({
    this.status = AnnouncementStatus.initial,
    this.announcements = const <Announcement>[],
    this.hasReachedMax = false,
    this.title,
    this.errorMsg,
    this.retrying = false,
  });

  final AnnouncementStatus status;
  final List<Announcement> announcements;
  final bool hasReachedMax;
  final String? title;
  final String? errorMsg;
  final bool retrying;

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<Announcement>? announcements,
    bool? hasReachedMax,
    String? title,
    String? errorMsg,
    bool? retrying,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      title: title ?? this.title,
      errorMsg: errorMsg ?? this.errorMsg,
      retrying: retrying ?? this.retrying,
    );
  }

  @override
  String toString() {
    return '''AnnouncementState { status: $status, annoucement: ${announcements.length}''';
  }

  @override
  List<Object?> get props =>
      [status, announcements, hasReachedMax, title, errorMsg];
}
