import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render.dart';

part 'generate_thumbnail_state.dart';

// Cubit directly class functions to emit state

class PdfThumbnailsCubit extends Cubit<PdfThumbnailsState> {
  PdfThumbnailsCubit() : super(PdfThumbnailsInitial());

  Future<void> generateThumbnails(String filePath) async {
    try {
      emit(PdfThumbnailsLoading());

      final pdfDoc = await PdfDocument.openFile(filePath);
      List<Uint8List> tempThumbnails = [];

      for (int i = 0; i < pdfDoc.pageCount; i++) {
        final page = await pdfDoc.getPage(i + 1);
        final pageImage = await page.render();
        final ui.Image image = await pageImage.createImageDetached();
        final ByteData? pngData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (pngData != null) {
          tempThumbnails.add(pngData.buffer.asUint8List());
        }
      }

      emit(PdfThumbnailsLoaded(thumbnails: tempThumbnails, totalPages: pdfDoc.pageCount));
    } catch (e) {
      debugPrint("Generate fail ${e.toString()}");
      emit(PdfThumbnailsError("Failed to generate thumbnails: ${e.toString()}"));
    }
  }
}

