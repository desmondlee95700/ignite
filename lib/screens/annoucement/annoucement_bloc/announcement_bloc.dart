import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Announcement.dart';
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
          .loadString('assets/json_model/announcement_data.json');
      final jsonResult = jsonDecode(data);

      final List? list = jsonResult['data'];
      final String? title = jsonResult['title'];

      final List<Announcement> announcements = list != null
          ? list.map((dynamic announcements) {
              final map = announcements as Map<String, dynamic>;
              return Announcement.fromJson(map);
            }).toList()
          : [];

      bool hasReachedMax = false;
      String nextKey = "";
      if (nextKey.isEmpty || announcements.isEmpty) {
        hasReachedMax = true;
      }

      return AnnnouncementAPIDetails(
        announcements: announcements,
        title: title,
        hasReachedMax: hasReachedMax,
      );
    } catch (error) {
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
