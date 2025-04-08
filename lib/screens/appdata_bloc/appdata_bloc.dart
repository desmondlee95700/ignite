import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/model/Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

part 'appdata_event.dart';
part 'appdata_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class AppDataBloc extends Bloc<AppDataEvent, AppDataState> {
  AppDataBloc() : super(const AppDataState()) {
    on<FetchAndCacheAppData>(_onFetchAndCacheAppData,
        transformer: throttleDroppable(throttleDuration));
  }

  Future<void> _onFetchAndCacheAppData(
      FetchAndCacheAppData event, Emitter<AppDataState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "Retrying...",
        retrying: true,
        status: AppDataStatus.loading,
      ));
    }

    try {
      final data = await _fetchData();

      if (data is AppDataDetails) {
        emit(state.copyWith(
          status: AppDataStatus.success,
          announcements: data.announcements,
          events: data.events,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: AppDataStatus.failure,
          errorMsg: data,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AppDataStatus.failure,
        errorMsg: "Failed to load and cache data: ${e.toString()}",
        retrying: false,
      ));
    }
  }

  Future<dynamic> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = FirebaseFirestore.instance;
      QuerySnapshot announcementSnapshot;
      QuerySnapshot eventSnapshot;

      // --- Annoucement ---
      announcementSnapshot = await db.collection("announcement_news").get();
      final List announceList = announcementSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['data'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final String announceTitle = announcementSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['title'] as String?; // Extract the title field
          })
          .where((announceTitle) =>
              announceTitle != null) // Filter out any null titles
          .join(', ');

      final announcements = announceList.map((dynamic articles) {
        final map = articles as Map<String, dynamic>;
        return Announcement.fromJson(map);
      }).toList();

      announcements.sort((a, b) {
        final dateA = a.post_date;
        final dateB = b.post_date;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      final List<String> announceJsonList = announcements
          .map((announcement) => jsonEncode(announcement.toJson()))
          .toList();
      await prefs.setStringList('saved_announcements', announceJsonList);
      await prefs.setString('saved_announcements_title', announceTitle);

      // --- Events ---
      eventSnapshot = await db.collection("event_news").get();
      final List eventList = eventSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['data'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final String eventTitle = eventSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['title'] as String?;
          })
          .where((eventTitle) => eventTitle != null)
          .join(', ');

      final events = eventList.map((dynamic articles) {
        final map = articles as Map<String, dynamic>;
        return Event.fromJson(map);
      }).toList();

      events.sort((a, b) {
        final dateA = a.start_post_date;
        final dateB = b.start_post_date;
        if (dateA == null || dateB == null) return 0;
        final yearA = dateA.year;
        final yearB = dateB.year;
        int result = yearB.compareTo(yearA);
        if (result == 0) {
          result = dateA.compareTo(dateB);
        }
        return result;
      });

      final List<String> eventJsonList = events
          .map((event) => jsonEncode(event.toJson()))
          .toList();
      await prefs.setStringList('saved_events', eventJsonList);
      await prefs.setString('saved_events_title', eventTitle);

      return AppDataDetails(
        announcements: announcements,
        events: events,
      );
    } catch (e) {
      return "Firebase Failed to fetch data: ${e.toString()}";
    }
  }
}

class AppDataDetails {
  final List<Announcement> announcements;
  final List<Event> events;

  AppDataDetails({
    required this.announcements,
    required this.events,
  });
}
