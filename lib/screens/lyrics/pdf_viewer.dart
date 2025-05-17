import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/lyrics/thumbnail_cubit_bloc/generate_thumbnail_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

class PDFViewer extends StatefulWidget {
  final String title;
  final String filePath;

  const PDFViewer({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  int? totalPages = 0;
  int? currentPage = 0;
  bool isReady = false;
  bool showPageSelector = false;
  String errorMessage = '';
  String _generateFilePath = "";
  List<Uint8List> thumbnails = [];

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl(widget.filePath);
  }

  Future<String> createFileOfPdfUrl(String url) async {
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();

      _generateFilePath = "${dir.path}/$filename";
      File file = File(_generateFilePath);
      await file.writeAsBytes(bytes, flush: true);
      context.read<PdfThumbnailsCubit>().generateThumbnails(_generateFilePath);

      return _generateFilePath;
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkThemeColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            HugeIcons.strokeRoundedArrowLeft02,
            size: 30,
            color: kPrimaryColor,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                        panEnabled: true,
                        minScale: 1,
                        maxScale: 4,
                        child: PDF(
                          swipeHorizontal: true,
                          enableSwipe: false,
                          autoSpacing: true,
                          defaultPage: 0,
                          fitPolicy: FitPolicy.BOTH,
                          fitEachPage: true,
                          preventLinkNavigation: false,
                          backgroundColor: Colors.black,
                          nightMode: true,
                          onRender: (pages) {
                            setState(() {
                              isReady = true;
                              totalPages = pages;
                            });
                          },
                        ).cachedFromUrl(widget.filePath)),
                    if (!isReady)
                      Center(
                        child: LoadingAnimationWidget.inkDrop(
                            color: kPrimaryColor, size: 50),
                      ),
                    if (errorMessage.isNotEmpty)
                      Center(
                        child: Text(errorMessage,
                            style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
              _buildPageNavigation(),
            ],
          ),

          // Page Selector Overlay (Ensures it's on top)
          if (showPageSelector)
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: SafeArea(
                child: BlocBuilder<PdfThumbnailsCubit, PdfThumbnailsState>(
                  builder: (context, state) {
                    if (state is PdfThumbnailsLoading) {
                      return _buildShimmerEffect();
                    } else if (state is PdfThumbnailsLoaded) {
                      return _buildThumbnailSelector(state.thumbnails);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: showPageSelector ? 150 : 0, // Ensure proper animation
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of placeholders
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnailSelector(List<Uint8List> thumbnails) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: showPageSelector ? 150 : 0, // Ensure proper animation
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 5)],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: thumbnails.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              final controller = await _controller.future;
              controller.setPage(index);
              setState(() {
                currentPage = index;
                showPageSelector = false; // Hide after selecting
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                    color: (currentPage == index)
                        ? kPrimaryColor
                        : Colors.transparent,
                    width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Stack(
                children: [
                  thumbnails.isNotEmpty
                      ? Image.memory(thumbnails[index],
                          width: 90, fit: BoxFit.fill)
                      : const Icon(HugeIcons.strokeRoundedImage01, size: 30),
                  Positioned(
                    bottom: 5,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: (currentPage == index)
                              ? kPrimaryColor
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: (currentPage == index)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageNavigation() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width,
          height: 3,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[300],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                // width: (totalPages != null && totalPages! > 0)
                //     ? (MediaQuery.of(context).size.width *
                //         ((currentPage ?? 0) / totalPages!))
                //     : 0,
                width: (totalPages != null && totalPages! > 1)
                    ? (MediaQuery.of(context).size.width *
                        ((currentPage ?? 0) / (totalPages! - 1))
                            .clamp(0.0, 1.0))
                    : 0,
                color: kPrimaryColor,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      showPageSelector = !showPageSelector;
                    });
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedArrowUp01,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2, // Make this part take more space to keep balance
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (currentPage! > 0) {
                        final controller = await _controller.future;
                        controller.setPage(currentPage! - 1);
                      }
                    },
                    icon: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: (currentPage! > 0)
                            ? kPrimaryColor
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_left_outlined,
                        size: 30,
                        color: (currentPage! > 0) ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   width: 50,
                  //   child: Center(
                  //     child: Text(
                  //       "${(currentPage! + 1).toString()} / $totalPages",
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 14,
                  //         color: kPrimaryColor,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(width: (10)),
                  Row(
                    children: [
                      Text(
                        (currentPage! + 1).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: kPrimaryColor,
                        ),
                      ),
                      SizedBox(width: (5)),
                      const Text(
                        "/",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: (5)),
                      Text(
                        "$totalPages",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: (10)),
                  IconButton(
                    onPressed: () async {
                      print("Logged total page $totalPages ");
                      if (currentPage! < (totalPages! - 1)) {
                        final controller = await _controller.future;
                        controller.setPage(currentPage! + 1);
                      }
                    },
                    icon: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        color: (currentPage! < (totalPages! - 1))
                            ? kPrimaryColor
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_outlined,
                        size: 30,
                        color: (currentPage! < (totalPages! - 1))
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
