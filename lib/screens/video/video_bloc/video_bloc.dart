import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Video.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await SharedPreferences.getInstance();

      final cachedMusicVideo = prefs.getStringList('saved_musicvideo');
      final cachedConferenceVideo =
          prefs.getStringList('saved_conferencevideo');
      final cachedLyricVideo = prefs.getStringList('saved_lyricvideo');

      final db = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot;

      String collectionName;
      String documentId;

      if (type == "musicvideo") {
        collectionName = 'music_video';
        documentId = 'music_video_posts';

        if (cachedMusicVideo != null) {
          print("Firebase music video cache");
          final musicVideos = cachedMusicVideo.map((jsonStr) {
            final Map<String, dynamic> map = jsonDecode(jsonStr);
            return Video.fromJson(map);
          }).toList();

          nextKey = null;

          bool hasReachedMax = false;
          if (nextKey == null || musicVideos.isEmpty) {
            hasReachedMax = true;
          }

          return ReelsApiDetails(
            videos: musicVideos,
            nextKey: nextKey,
            hasReachedMax: hasReachedMax,
          );
        }
      } else if (type == "lyricvideo") {
        collectionName = 'lyric_video';
        documentId = 'lyric_video_posts';

        if (cachedLyricVideo != null) {
          print("Firebase lyric video cache");
          final lyricVideos = cachedLyricVideo.map((jsonStr) {
            final Map<String, dynamic> map = jsonDecode(jsonStr);
            return Video.fromJson(map);
          }).toList();

          nextKey = null;

          bool hasReachedMax = false;
          if (nextKey == null || lyricVideos.isEmpty) {
            hasReachedMax = true;
          }

          return ReelsApiDetails(
            videos: lyricVideos,
            nextKey: nextKey,
            hasReachedMax: hasReachedMax,
          );
        }
      } else if (type == "conferencevideo") {
        collectionName = 'conference_video';
        documentId = 'conference_video_posts';

        if (cachedConferenceVideo != null) {
          print("Firebase conference video cache");
          final conferenceVideos = cachedConferenceVideo.map((jsonStr) {
            final Map<String, dynamic> map = jsonDecode(jsonStr);
            return Video.fromJson(map);
          }).toList();

          nextKey = null;

          bool hasReachedMax = false;
          if (nextKey == null || conferenceVideos.isEmpty) {
            hasReachedMax = true;
          }

          return ReelsApiDetails(
            videos: conferenceVideos,
            nextKey: nextKey,
            hasReachedMax: hasReachedMax,
          );
        }
      } else {
        throw ArgumentError('Unsupported type: $type');
      }

      // if (nextKey != null) {
      //   final lastDocument =
      //       await db.collection(collectionName).doc(documentId).get();

      //   querySnapshot = await db
      //       .collection(collectionName)
      //       .orderBy('post_date')
      //       .startAfterDocument(lastDocument)
      //       .get();
      // } else {
      //   querySnapshot = await db.collection(collectionName).get();
      // }

      // --- If no cache exists, fetch from Firestore ---
      querySnapshot = await db.collection(collectionName).get();

      final List list = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['posts'] ?? [];
          })
          .expand((element) => element)
          .toList();

      if (list.length <= 10) {
        nextKey = null;
      } else {
        nextKey = null;
      }

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
    } catch (error) {
      print("Video bloc $error");
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
