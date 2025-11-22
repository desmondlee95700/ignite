import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'announcement_event.dart';

part 'announcement_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  AnnouncementBloc({required this.httpClient})
      : super(const AnnouncementState()) {
    on<FetchAnnouncement>(_onCollectionFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  final http.Client httpClient;

  Future<void> _onCollectionFetched(
      FetchAnnouncement event, Emitter<AnnouncementState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "",
        retrying: true,
        hasReachedMax: false,
        announcements: [],
        title: null,
      ));
    }

    if (state.hasReachedMax) return;

    try {
      final apiDetails = await _fetchCollection();

      if (apiDetails is AnnnouncementAPIDetails) {
        return emit(state.copyWith(
          status: AnnouncementStatus.success,
          announcements: apiDetails.announcements,
          hasReachedMax: apiDetails.hasReachedMax,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: AnnouncementStatus.failure,
          errorMsg: apiDetails,
          announcements: state.announcements,
          hasReachedMax: true,
          title: null,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AnnouncementStatus.failure,
        errorMsg:
            "Temporarily unable to load Ignite due to technical difficulties, please try again later...",
        announcements: state.announcements,
        hasReachedMax: true,
        title: null,
        retrying: false,
      ));
    }
  }

  Future<dynamic> _fetchCollection() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // --- Load cache ---
      final cachedData = prefs.getStringList('saved_announcements');

      if (cachedData != null) {
        print("Supabase announcement cache");

        final announcements = cachedData.map((jsonStr) {
          return Announcement.fromJson(jsonDecode(jsonStr));
        }).toList();

        // Sort cache by latest post_date
        announcements.sort((a, b) {
          final dateA = a.post_date;
          final dateB = b.post_date;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return AnnnouncementAPIDetails(
          announcements: announcements,
          hasReachedMax: true,
        );
      }

      // --- No cache, fetch from Supabase ---
      print("Supabase announcement no cache");

      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('announcement')
          .select()
          .order('post_date', ascending: false);

      // Convert response → List<Announcement>
      final announcements = (response as List<dynamic>)
          .map((row) => Announcement.fromJson(row))
          .toList();

      // Cache results
      final jsonList =
          announcements.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('saved_announcements', jsonList);

      return AnnnouncementAPIDetails(
        announcements: announcements,
        hasReachedMax: true,
      );
    } catch (error) {
      print("Failed to load announcements: $error");
      return "Temporarily unable to load Ignite due to technical difficulties, please try again later...";
    }
  }
}

class AnnnouncementAPIDetails {
  final List<Announcement> announcements;
  final bool hasReachedMax;

  AnnnouncementAPIDetails({
    required this.announcements,
    required this.hasReachedMax,
  });
}
