import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Event.dart';
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
      final db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot;

      querySnapshot = await db.collection("event_news").get();

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
            return data['title'] as String?; // Extract the title field
          })
          .where((title) => title != null) // Filter out any null titles
          .join(', ');

      final events = list.map((dynamic articles) {
        final map = articles as Map<String, dynamic>;
        return Event.fromJson(map);
      }).toList();

      // Sort events by year (descending order) and then by start_post_date
      events.sort((a, b) {
        final dateA =
            a.start_post_date; // Assuming start_post_date is a Timestamp
        final dateB = b.start_post_date;

        // Handle null or invalid timestamps
        if (dateA == null || dateB == null) return 0;

        // First sort by year (descending order)
        final yearA = dateA.toDate().year;
        final yearB = dateB.toDate().year;
        int result =
            yearB.compareTo(yearA); // Reversed to sort by year (descending)

        // If years are the same, sort by date
        if (result == 0) {
          result = dateA.compareTo(dateB); // Sort by date if years are the same
        }

        return result;
      });

      bool hasReachedMax = false;
      String nextKey = "";
      if (nextKey.isEmpty || events.isEmpty) {
        hasReachedMax = true;
      }

      return EventAPIDetails(
        events: events,
        title: title,
        hasReachedMax: hasReachedMax,
      );
    } catch (error) {
      print("Eventbloc $error");
      return "Temporarily unable to load Ignite due to technical difficulties, please try again later...";
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
