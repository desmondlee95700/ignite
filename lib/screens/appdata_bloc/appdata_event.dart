part of 'appdata_bloc.dart';

sealed class AppDataEvent extends Equatable {
  const AppDataEvent();

  @override
  List<Object?> get props => [];
}

final class FetchAndCacheAppData extends AppDataEvent {
  FetchAndCacheAppData({
    this.retrying,
  });

  final bool? retrying;
}
