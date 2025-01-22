part of 'announcement_bloc.dart';

sealed class AnnouncementEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FetchAnnouncement extends AnnouncementEvent {
  FetchAnnouncement({
    this.retrying,
  });

  final bool? retrying;
}
