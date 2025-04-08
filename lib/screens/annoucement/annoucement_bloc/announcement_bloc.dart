import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Announcement.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

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
        errorMsg: "Retrying...",
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
          title: apiDetails.title,
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

      final cachedData = prefs.getStringList('saved_announcements');
      final cachedTitle = prefs.getString('saved_announcements_title');

      if (cachedData != null && cachedTitle != null) {
        print("Firebase announcment cache");
        final announcements = cachedData.map((jsonStr) {
          final Map<String, dynamic> map = jsonDecode(jsonStr);
          return Announcement.fromJson(map);
        }).toList();

        // Sort by most recent post date
        announcements.sort((a, b) {
          final dateA = a.post_date;
          final dateB = b.post_date;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return AnnnouncementAPIDetails(
          announcements: announcements,
          title: cachedTitle,
          hasReachedMax: true,
        );
      }

      // --- If no cache exists, fetch from Firestore ---
      print("Firebase announcment no cache");
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection("announcement_news").get();

      final List list = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['data'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final String title = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['title'] as String?;
          })
          .where((t) => t != null)
          .join(', ');

      final announcements = list.map((dynamic article) {
        final map = article as Map<String, dynamic>;
        return Announcement.fromJson(map);
      }).toList();

      // Sort announcements by most recent post date
      announcements.sort((a, b) {
        final dateA = a.post_date;
        final dateB = b.post_date;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });

      // Cache to SharedPreferences
      final jsonList =
          announcements.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('saved_announcements', jsonList);
      await prefs.setString('saved_announcements_title', title);

      return AnnnouncementAPIDetails(
        announcements: announcements,
        title: title,
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
  final String? title;
  final bool hasReachedMax;

  AnnnouncementAPIDetails({
    required this.announcements,
    required this.title,
    required this.hasReachedMax,
  });
}
