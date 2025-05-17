// 
part of 'generate_thumbnail_cubit.dart';

abstract class PdfThumbnailsState extends Equatable {
  const PdfThumbnailsState();

  @override
  List<Object?> get props => [];
}

class PdfThumbnailsInitial extends PdfThumbnailsState {}

class PdfThumbnailsLoading extends PdfThumbnailsState {}

class PdfThumbnailsLoaded extends PdfThumbnailsState {
  final List<Uint8List> thumbnails;
  final int totalPages;

  const PdfThumbnailsLoaded({required this.thumbnails, required this.totalPages});

  @override
  List<Object?> get props => [thumbnails, totalPages];
}

class PdfThumbnailsLoadedMulti extends PdfThumbnailsState {
  final Map<String, List<Uint8List>> thumbnailsMap;
  final int totalPages;

  const PdfThumbnailsLoadedMulti({required this.thumbnailsMap, required this.totalPages});

  @override
  List<Object?> get props => [thumbnailsMap, totalPages];
}

class PdfThumbnailsError extends PdfThumbnailsState {
  final String message;

  const PdfThumbnailsError(this.message);

  @override
  List<Object?> get props => [message];
}
