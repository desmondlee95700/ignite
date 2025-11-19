import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/model/Lyrics.dart';
import 'package:ignite/model/Video.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      //QuerySnapshot lyricsSnapshot;
      QuerySnapshot musicVideoSnapshot;
      QuerySnapshot conferenceVideoSnapshot;
      QuerySnapshot lyricVideoSnapshot;

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

      final announcements = announceList.map((dynamic annoucements) {
        final map = annoucements as Map<String, dynamic>;
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

      final events = eventList.map((dynamic events) {
        final map = events as Map<String, dynamic>;
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

      final List<String> eventJsonList =
          events.map((event) => jsonEncode(event.toJson())).toList();
      await prefs.setStringList('saved_events', eventJsonList);
      await prefs.setString('saved_events_title', eventTitle);

      // --- Lyrics ---
      final lyricsResponse = await Supabase.instance.client
          .from('lyrics')
          .select()
          .order('id', ascending: true);

      final lyrics = (lyricsResponse as List<dynamic>)
          .map((l) => Lyrics.fromJson(l as Map<String, dynamic>))
          .toList();

      final List<String> lyricsJsonList =
          lyrics.map((lyric) => jsonEncode(lyric.toJson())).toList();
      await prefs.setStringList('saved_lyrics', lyricsJsonList);

      // lyricsSnapshot = await db.collection("lyrics_files").get();
      // final List lyricsList = lyricsSnapshot.docs
      //     .map((doc) {
      //       final data = doc.data() as Map<String, dynamic>;
      //       return data['posts'] ?? [];
      //     })
      //     .expand((element) => element)
      //     .toList();

      // final lyrics = lyricsList.map((dynamic lyrics) {
      //   final map = lyrics as Map<String, dynamic>;
      //   return Lyrics.fromJson(map);
      // }).toList();

      // final List<String> lyricsJsonList =
      //     lyrics.map((lyric) => jsonEncode(lyric.toJson())).toList();
      // await prefs.setStringList('saved_lyrics', lyricsJsonList);

      // --- Video ---
      //music video
      musicVideoSnapshot = await db.collection("music_video").get();
      final List musicVideoList = musicVideoSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['posts'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final musicVideo = musicVideoList.map((dynamic musicvideos) {
        final map = musicvideos as Map<String, dynamic>;
        return Video.fromJson(map);
      }).toList();

      final List<String> musicVideoJsonList = musicVideo
          .map((musicvideo) => jsonEncode(musicvideo.toJson()))
          .toList();
      await prefs.setStringList('saved_musicvideo', musicVideoJsonList);

      //conference video
      conferenceVideoSnapshot = await db.collection("conference_video").get();
      final List conferenceVideoList = conferenceVideoSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['posts'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final conferenceVideo =
          conferenceVideoList.map((dynamic conferencevideos) {
        final map = conferencevideos as Map<String, dynamic>;
        return Video.fromJson(map);
      }).toList();

      final List<String> conferenceVideoJsonList = conferenceVideo
          .map((conferencevideo) => jsonEncode(conferencevideo.toJson()))
          .toList();
      await prefs.setStringList(
          'saved_conferencevideo', conferenceVideoJsonList);

      //lyric video
      lyricVideoSnapshot = await db.collection("lyric_video").get();
      final List lyricVideoList = lyricVideoSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['posts'] ?? [];
          })
          .expand((element) => element)
          .toList();

      final lyricVideo = lyricVideoList.map((dynamic lyricvideos) {
        final map = lyricvideos as Map<String, dynamic>;
        return Video.fromJson(map);
      }).toList();

      final List<String> lyricVideoJsonList = lyricVideo
          .map((lyricvideo) => jsonEncode(lyricvideo.toJson()))
          .toList();
      await prefs.setStringList('saved_lyricvideo', lyricVideoJsonList);

      return AppDataDetails(
          announcements: announcements,
          events: events,
          lyrics: lyrics,
          musicVideos: musicVideo,
          conferenceVideos: conferenceVideo,
          lyricVideos: lyricVideo);
    } catch (e) {
      return "Firebase Failed to fetch data: ${e.toString()}";
    }
  }
}

class AppDataDetails {
  final List<Announcement> announcements;
  final List<Event> events;
  final List<Lyrics> lyrics;
  final List<Video> musicVideos;
  final List<Video> conferenceVideos;
  final List<Video> lyricVideos;

  AppDataDetails(
      {required this.announcements,
      required this.events,
      required this.lyrics,
      required this.musicVideos,
      required this.conferenceVideos,
      required this.lyricVideos});
}
