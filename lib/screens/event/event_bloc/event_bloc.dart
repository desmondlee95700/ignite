import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
  EventBloc({required this.httpClient})
      : super(const EventState()) {
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
      // String url = "${apiURL}main_topic/v2";

      // final response = await http.get(Uri.parse(url));

      // if (response.statusCode == 200) {
      //   final body = json.decode(response.body);
      //   final List? list = body['data'];
      //   final String? title = body['title'];

      //   final List<Announcement> announcements = list != null
      //       ? list.map((dynamic announcements) {
      //           final map = announcements as Map<String, dynamic>;
      //           return Announcement.fromJson(map);
      //         }).toList()
      //       : [];

      //   return AnnnouncementAPIDetails(
      //     announcements: announcements,
      //     title: title,
      //   );
      // } else {
      //   return "Temporarily unable to load Sinar Daily, please try again later...";
      // }

      // Load the chosen JSON file
      String data = await rootBundle
          .loadString('assets/json_model/event_data.json');
      final jsonResult = jsonDecode(data);

      final List? list = jsonResult['data'];
      final String? title = jsonResult['title'];

      final List<Event> events = list != null
          ? list.map((dynamic events) {
              final map = events as Map<String, dynamic>;
              return Event.fromJson(map);
            }).toList()
          : [];

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
