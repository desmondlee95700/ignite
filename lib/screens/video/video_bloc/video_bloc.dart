import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Video.dart';
import 'package:stream_transform/stream_transform.dart';

part 'video_event.dart';

part 'video_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc({required this.httpClient}) : super(const VideoState()) {
    on<FetchVideo>(_onReelsFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  final http.Client httpClient;

  Future<void> _onReelsFetched(
      FetchVideo event, Emitter<VideoState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "Retrying...",
        retrying: true,
        hasReachedMax: false,
        videos: [],
        nextKey: null,
      ));
    }

    if (state.hasReachedMax) return;

    try {
      final apiDetails =
          await _fetchReels(nextKey: event.nextKey, type: event.type);

      if (apiDetails is ReelsApiDetails) {
        return emit(state.copyWith(
          status: VideoStatus.success,
          videos: List.of(state.videos)..addAll(apiDetails.videos),
          hasReachedMax: apiDetails.hasReachedMax,
          nextKey: apiDetails.nextKey,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: VideoStatus.failure,
          errorMsg: apiDetails,
          videos: state.videos,
          hasReachedMax: true,
          nextKey: null,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VideoStatus.failure,
        errorMsg:
            "Temporarily unable to load Ignite Content due to technical difficulties, please try again later...",
        videos: state.videos,
        hasReachedMax: true,
        nextKey: null,
        retrying: false,
      ));
    }
  }

  Future<dynamic> _fetchReels({String? nextKey, String? type}) async {
    try {
      // String url = "${apiURL}posts/video/random";

      // if (nextKey != null) {
      //   url += "?next=$nextKey";
      // }

      // final response = await http.get(Uri.parse(url));

      // if (response.statusCode == 200) {
      //   final body = json.decode(response.body);
      //   final List list = body['posts'];
      //   final String? nextKey = body['next'];

      //   final reels = list.map((dynamic articles) {
      //     final map = articles as Map<String, dynamic>;
      //     return Reels.fromJson(map);
      //   }).toList();

      //   bool hasReachedMax = false;
      //   if (nextKey == null || reels.isEmpty) {
      //     hasReachedMax = true;
      //   }

      //   return ReelsApiDetails(
      //     reels: reels,
      //     nextKey: nextKey,
      //     hasReachedMax: hasReachedMax,
      //   );
      // } else {
      //   return "Temporarily unable to load Sinar Daily, please try again later...";
      // }
      // Load JSON from local asset

      String fileName;

      // Choose the file based on the type
      if (type == "musicvideo") {
        fileName = 'assets/json_model/music_video.json';
      } else if (type == "conference") {
        fileName = 'assets/json_model/conference_video.json';
      } else {
        fileName = 'assets/json_model/lyrics_video.json';
      }

      // Load the chosen JSON file
      String data = await rootBundle.loadString(fileName);
      final jsonResult = jsonDecode(data);

      final List list = jsonResult['posts'];
      final String? nextKey = jsonResult['next'];

      final videos = list.map((dynamic articles) {
        final map = articles as Map<String, dynamic>;
        return Video.fromJson(map);
      }).toList();

      bool hasReachedMax = false;
      if (nextKey == null || videos.isEmpty) {
        hasReachedMax = true;
      }

      return ReelsApiDetails(
        videos: videos,
        nextKey: nextKey,
        hasReachedMax: hasReachedMax,
      );
    } catch (error, st) {
      print(error);
      print(st);
      return "Temporarily unable to load Ignite Content due to technical difficulties, please try again later...";
    }
  }
}

class ReelsApiDetails {
  final List<Video> videos;
  final String? nextKey;
  final bool hasReachedMax;

  ReelsApiDetails({
    required this.videos,
    required this.nextKey,
    required this.hasReachedMax,
  });
}
