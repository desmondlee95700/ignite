import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

part 'generate_thumbnail_state.dart';

// Cubit directly class functions to emit state

class PdfThumbnailsCubit extends Cubit<PdfThumbnailsState> {
  PdfThumbnailsCubit() : super(PdfThumbnailsInitial());

  Future<void> generateThumbnails(String filePath) async {
    try {
      emit(PdfThumbnailsLoading());

      final pdfDoc = await PdfDocument.openFile(filePath);
      final List<Uint8List> thumbnails = [];

      for (int index = 1; index <= pdfDoc.pagesCount; index++) {
        final page = await pdfDoc.getPage(index);
        final pageImage = await page.render(
          width: 250, // lower resolution
          height: (page.height * 250 / page.width).toDouble(),
          format: PdfPageImageFormat.png,
        );

        await page.close(); // Properly close page after rendering

        if (pageImage!.bytes.isNotEmpty) {
          thumbnails.add(pageImage.bytes);
        }
      }

      await pdfDoc.close();

      emit(PdfThumbnailsLoaded(
        thumbnails: thumbnails,
        totalPages: pdfDoc.pagesCount,
      ));
    } catch (e) {
      debugPrint("Generate fail ${e.toString()}");
      emit(
          PdfThumbnailsError("Failed to generate thumbnails: ${e.toString()}"));
    }
  }
}
