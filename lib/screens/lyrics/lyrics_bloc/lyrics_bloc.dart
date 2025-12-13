import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/Lyrics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'lyrics_event.dart';

part 'lyrics_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  LyricsBloc({required this.httpClient}) : super(const LyricsState()) {
    on<FetchLyrics>(_onCollectionFetched,
        transformer: throttleDroppable(throttleDuration));
  }

  final http.Client httpClient;

  Future<void> _onCollectionFetched(
      FetchLyrics event, Emitter<LyricsState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "Retrying...",
        retrying: true,
        hasReachedMax: false,
        lyrics: [],
        title: null,
      ));
    }

    if (state.hasReachedMax) return;

    try {
      final apiDetails = await _fetchCollection();

      if (apiDetails is LyricsAPIDetails) {
        return emit(state.copyWith(
          status: LyricsStatus.success,
          lyrics: apiDetails.lyrics,
          hasReachedMax: apiDetails.hasReachedMax,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: LyricsStatus.failure,
          errorMsg: apiDetails,
          lyrics: state.lyrics,
          hasReachedMax: true,
          title: null,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LyricsStatus.failure,
        errorMsg:
            "Temporarily unable to load Ignite due to technical difficulties, please try again later...",
        lyrics: state.lyrics,
        hasReachedMax: true,
        title: null,
        retrying: false,
      ));
    }
  }

  // Future<dynamic> _fetchCollection() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();

  //     final cachedData = prefs.getStringList('saved_lyrics');

  //     if (cachedData != null) {
  //       print("Firebase lyrics cache");
  //       final lyrics = cachedData.map((jsonStr) {
  //         final Map<String, dynamic> map = jsonDecode(jsonStr);
  //         return Lyrics.fromJson(map);
  //       }).toList();

  //       return LyricsAPIDetails(
  //         lyrics: lyrics,
  //         hasReachedMax: true,
  //       );
  //     }

  //     // --- If no cache exists, fetch from Firestore ---
  //     print("Firebase lyrics no cache");
  //     final db = FirebaseFirestore.instance;
  //     final querySnapshot = await db.collection("lyrics_files").get();

  //     final List list = querySnapshot.docs
  //         .map((doc) {
  //           final data = doc.data() as Map<String, dynamic>;
  //           return data['posts'] ?? [];
  //         })
  //         .expand((element) => element)
  //         .toList();

  //     final lyrics = list.map((dynamic article) {
  //       final map = article as Map<String, dynamic>;
  //       return Lyrics.fromJson(map);
  //     }).toList();

  //     // Cache to SharedPreferences
  //     final jsonList =
  //         lyrics.map((a) => jsonEncode(a.toJson())).toList();
  //     await prefs.setStringList('saved_lyrics', jsonList);

  //     return LyricsAPIDetails(
  //       lyrics: lyrics,
  //       hasReachedMax: true,
  //     );
  //   } catch (error) {
  //     print("Failed to load lyrics: $error");
  //     return "Temporarily unable to load Ignite due to technical difficulties, please try again later...";
  //   }
  // }
  Future<dynamic> _fetchCollection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getStringList('saved_lyrics');

      // --- If cache exists ---
      if (cachedData != null) {
        print("Supabase lyrics cache");
        final lyrics = cachedData.map((jsonStr) {
          final Map<String, dynamic> map = jsonDecode(jsonStr);
          return Lyrics.fromJson(map);
        }).toList();

        return LyricsAPIDetails(
          lyrics: lyrics,
          hasReachedMax: true,
        );
      }

      // --- Fetch from Supabase ---
      print("Supabase lyrics no cache");

      final supabase = Supabase.instance.client;

      try {
        final response =
            await supabase.from('lyrics').select().order('id', ascending: true);
        // Convert list<dynamic> → List<Lyrics>
        final lyrics = (response as List<dynamic>)
            .map((item) => Lyrics.fromJson(item as Map<String, dynamic>))
            .toList();

        // Save to SharedPreferences cache
        final jsonList = lyrics.map((l) => jsonEncode(l.toJson())).toList();
        await prefs.setStringList('saved_lyrics', jsonList);
        return LyricsAPIDetails(
          lyrics: lyrics,
          hasReachedMax: true,
        );
      } catch (e) {
        debugPrint("Supabase response $e");
        return LyricsAPIDetails(
          lyrics: [],
          hasReachedMax: true,
        );
      }
    } catch (error) {
      print("Failed to load lyrics: $error");
      return "Temporarily unable to load Ignite due to technical difficulties, please try again later...";
    }
  }
}

class LyricsAPIDetails {
  final List<Lyrics> lyrics;
  final bool hasReachedMax;

  LyricsAPIDetails({
    required this.lyrics,
    required this.hasReachedMax,
  });
}
