import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/model/Lyrics.dart';
import 'package:ignite/model/MusicItem.dart';
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

      QuerySnapshot eventSnapshot;
      QuerySnapshot musicVideoSnapshot;
      QuerySnapshot conferenceVideoSnapshot;
      QuerySnapshot lyricVideoSnapshot;

      // --- Annoucement ---
      final announcementResponse = await Supabase.instance.client
          .from('announcements')
          .select()
          .order('id', ascending: true);
      final announcements = (announcementResponse as List<dynamic>)
          .map((l) => Announcement.fromJson(l as Map<String, dynamic>))
          .toList();
      announcements.sort((a, b) {
        final dateA = a.post_date;
        final dateB = b.post_date;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });
      final List<String> announcementJsonList = announcements
          .map((announcement) => jsonEncode(announcement.toJson()))
          .toList();
      debugPrint("Supabase annoucment result $announcementJsonList");
      await prefs.setStringList('saved_announcements', announcementJsonList);

      // --- Events ---
      final eventResponse = await Supabase.instance.client
          .from('events')
          .select()
          .order('id', ascending: true);
      final events = (eventResponse as List<dynamic>)
          .map((l) => Event.fromJson(l as Map<String, dynamic>))
          .toList();
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

      // --- Music Item ---
      final musicItemsResponse = await Supabase.instance.client
          .from('music_items')
          .select()
          .order('created_at', ascending: false);
      final musicItems = (musicItemsResponse as List<dynamic>)
          .map((l) => MusicItem.fromJson(l as Map<String, dynamic>))
          .toList();
      musicItems.sort((a, b) {
        final dateA = a.createdAt;
        final dateB = b.createdAt;
        if (dateA == null || dateB == null) return 0;
        return dateB.compareTo(dateA);
      });
      final List<String> musicItemsJsonList =
          musicItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('saved_music_items', musicItemsJsonList);
      debugPrint("Supabase music items cached: ${musicItems.length}");

      return AppDataDetails(
          announcements: announcements,
          events: events,
          lyrics: lyrics,
          music_item: musicItems);
    } catch (e) {
      return "Firebase Failed to fetch data: ${e.toString()}";
    }
  }
}

class AppDataDetails {
  final List<Announcement> announcements;
  final List<Event> events;
  final List<Lyrics> lyrics;
  final List<MusicItem> music_item;

  AppDataDetails(
      {required this.announcements,
      required this.events,
      required this.lyrics,
      required this.music_item});
}
