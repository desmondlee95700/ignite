import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/model/MusicItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your MusicItem model
// import 'package:ignite/model/music_item.dart';

part 'musicitem_event.dart';
part 'musicitem_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class MusicItemBloc extends Bloc<MusicItemEvent, MusicItemState> {
  MusicItemBloc({required this.httpClient}) : super(const MusicItemState()) {
    on<FetchMusicItem>(
      _onMusicFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onMusicFetched(
      FetchMusicItem event, Emitter<MusicItemState> emit) async {
    if (event.retrying != null && event.retrying!) {
      emit(state.copyWith(
        errorMsg: "Retrying...",
        retrying: true,
        hasReachedMax: false,
        musicItems: [],
      ));
    }

    if (state.hasReachedMax) return;

    try {
      final apiDetails = await _fetchMusic();

      if (apiDetails is MusicAPIDetails) {
        return emit(state.copyWith(
          status: MusicItemStatus.success,
          musicItems: apiDetails.musicItems,
          hasReachedMax: apiDetails.hasReachedMax,
          retrying: false,
          errorMsg: null,
        ));
      } else {
        emit(state.copyWith(
          status: MusicItemStatus.failure,
          errorMsg: apiDetails,
          musicItems: state.musicItems,
          hasReachedMax: true,
          retrying: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: MusicItemStatus.failure,
        errorMsg:
            "Temporarily unable to load music due to technical difficulties, please try again later...",
        musicItems: state.musicItems,
        hasReachedMax: true,
        retrying: false,
      ));
    }
  }

  Future<dynamic> _fetchMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // --- Load cache ---
      final cachedData = prefs.getStringList('saved_music_items');

      if (cachedData != null) {
        print("Supabase music cache");

        final musicItems = cachedData.map((jsonStr) {
          return MusicItem.fromJson(jsonDecode(jsonStr));
        }).toList();

        // Sort by created_at (newest first)
        musicItems.sort((a, b) {
          final dateA = a.createdAt;
          final dateB = b.createdAt;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return MusicAPIDetails(
          musicItems: musicItems,
          hasReachedMax: true,
        );
      }

      // --- No cache, fetch from Supabase ---
      print("Supabase music no cache");

      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('music_items') // Change to your table name
          .select()
          .order('created_at', ascending: false);

      // Convert response → List<MusicItem>
      final musicItems = (response as List<dynamic>)
          .map((row) => MusicItem.fromJson(row))
          .toList();

      // Cache results
      final jsonList = musicItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('saved_music_items', jsonList);

      return MusicAPIDetails(
        musicItems: musicItems,
        hasReachedMax: true,
      );
    } catch (error) {
      print("Failed to load music: $error");
      return "Temporarily unable to load music due to technical difficulties, please try again later...";
    }
  }
}

class MusicAPIDetails {
  final List<MusicItem> musicItems;
  final bool hasReachedMax;

  MusicAPIDetails({
    required this.musicItems,
    required this.hasReachedMax,
  });
}