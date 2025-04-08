import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

part 'event_event.dart';

part 'event_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc({required this.httpClient}) : super(const EventState()) {
    on<FetchEvent>(_onEventFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  final http.Client httpClient;

  Future<void> _onEventFetched(
      FetchEvent event, Emitter<EventState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "Retrying...",
        retrying: true,
        hasReachedMax: false,
        events: [],
        title: null,
      ));
    }

    if (state.hasReachedMax) return;

    try {
      final apiDetails = await _fetchCollection();

      if (apiDetails is EventAPIDetails) {
        return emit(state.copyWith(
          status: EventStatus.success,
          events: apiDetails.events,
          hasReachedMax: apiDetails.hasReachedMax,
          title: apiDetails.title,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: EventStatus.failure,
          errorMsg: apiDetails,
          events: state.events,
          hasReachedMax: true,
          title: null,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        errorMsg:
            "Temporarily unable to load Ignite due to technical difficulties, please try again later...",
        events: state.events,
        hasReachedMax: true,
        title: null,
        retrying: false,
      ));
    }
  }

  Future<dynamic> _fetchCollection() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if cached events exist in SharedPreferences
      final cachedData = prefs.getStringList('saved_events');
      final cachedTitle = prefs.getString('saved_events_title');

      if (cachedData != null && cachedTitle != null) {
        print("Firebase event cache");
        final events = cachedData.map((jsonStr) {
          final Map<String, dynamic> map = jsonDecode(jsonStr);
          return Event.fromJson(map);
        }).toList();

        // Sort events by most recent start_post_date
        events.sort((a, b) {
          final dateA = a.start_post_date;
          final dateB = b.start_post_date;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return EventAPIDetails(
          events: events,
          title: cachedTitle,
          hasReachedMax: true,
        );
      }

      // --- If no cache exists, fetch from Firestore ---
      print("Firebase event no cache");
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection("event_news").get();

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

      final events = list.map((dynamic article) {
        final map = article as Map<String, dynamic>;
        return Event.fromJson(map);
      }).toList();

      // Sort events by year (descending order) and then by start_post_date
      events.sort((a, b) {
        final dateA = a.start_post_date;
        final dateB = b.start_post_date;

        if (dateA == null || dateB == null) return 0;

        final yearA = dateA.year;
        final yearB = dateB.year;
        int result = yearB.compareTo(yearA); // Reversed for descending order

        // If years are the same, sort by date
        if (result == 0) {
          result = dateA.compareTo(dateB);
        }
        return result;
      });

      // Cache the results in SharedPreferences
      final jsonList = events.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('saved_events', jsonList);
      await prefs.setString('saved_events_title', title);

      return EventAPIDetails(
        events: events,
        title: title,
        hasReachedMax: true,
      );
    } catch (error) {
      print("EventBloc error: $error");
      return "Temporarily unable to load events, please try again later...";
    }
  }
}

class EventAPIDetails {
  final List<Event> events;
  final String? title;
  final bool hasReachedMax;

  EventAPIDetails({
    required this.events,
    required this.title,
    required this.hasReachedMax,
  });
}
