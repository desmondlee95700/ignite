import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // --- Check cached events ---
      final cachedData = prefs.getStringList('saved_events');

      if (cachedData != null) {
        print("Supabase event cache");

        final events = cachedData.map((jsonStr) {
          final Map<String, dynamic> map = jsonDecode(jsonStr);
          return Event.fromJson(map);
        }).toList();

        // Sort by year → then by start date
        events.sort((a, b) {
          final dateA = a.start_post_date;
          final dateB = b.start_post_date;

          if (dateA == null || dateB == null) return 0;

          final yearA = dateA.year;
          final yearB = dateB.year;

          int result = yearB.compareTo(yearA); // Descending year
          if (result == 0) {
            result = dateA.compareTo(dateB); // Ascending date
          }

          return result;
        });

        return EventAPIDetails(
          events: events,
          hasReachedMax: true,
        );
      }

      // --- No cache → fetch from Supabase ---
      print("Supabase event no cache");

      final supabase = Supabase.instance.client;

      // Fetch all rows ordered by id
      final response = await supabase
          .from('events')
          .select('*')
          .order('id', ascending: true);

      final events = (response as List<dynamic>)
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort events (same as above)
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

      // Cache results
      final jsonList = events.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('saved_events', jsonList);

      return EventAPIDetails(
        events: events,
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
  final bool hasReachedMax;

  EventAPIDetails({
    required this.events,
    required this.hasReachedMax,
  });
}
