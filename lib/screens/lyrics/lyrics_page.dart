import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/lyrics/lyrics_bloc/lyrics_bloc.dart';
import 'package:ignite/screens/lyrics/pdf_viewer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class LyricsPage extends StatefulWidget {
  final ScrollController controller;

  const LyricsPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final LyricsBloc lyricsBloc = LyricsBloc(httpClient: http.Client());

  @override
  void initState() {
    super.initState();
    lyricsBloc.add(FetchLyrics());
  }

  void openPDF(BuildContext context, String url, String title) async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingAnimationWidget.inkDrop(color: kPrimaryColor, size: 50);
      },
    );

    try {

      // Dismiss loader
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to PDFViewer
      if (context.mounted) {
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              duration: const Duration(milliseconds: 600),
              reverseDuration: const Duration(milliseconds: 600),
              isIos: true,
              child: PDFViewer(
                title: title,
                filePath: url,
              )),
        );
      }
    } catch (e) {
      // Dismiss loader if an error occurs
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            floating: true,
            snap: true,
            surfaceTintColor: Colors.transparent,
            title: Text(
              " | Ignite Lyrics",
              style: TextStyle(
                color: kPrimaryColor,
                fontFamily: 'Manrope',
                fontSize: 18,
              ),
            ),
          ),
        ];
      },
      body: BlocProvider(
        create: (_) => lyricsBloc,
        child: BlocBuilder<LyricsBloc, LyricsState>(
          builder: (context, state) {
            if (state.status == LyricsStatus.initial) {
              return GridView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 200,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              );
            } else if (state.status == LyricsStatus.success) {
              return RefreshIndicator(
                onRefresh: () async {
                  lyricsBloc.add(FetchLyrics(retrying: true));
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: state.lyrics.length,
                  itemBuilder: (context, index) {
                    final lyric = state.lyrics[index];
                    return InkWell(
                      onTap: (){
                        openPDF(context, lyric.pdf_url, lyric.title);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: lyric.image_url,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 250,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) {
                                  return Container(
                                    height: 250,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) {
                                  return Container(
                                    height: 250,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          "assets/images/ignite_icon.jpg",
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    lyric.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Manrope',
                                      color: Colors.white,
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
            } else if (state.status == LyricsStatus.failure) {
              return Center(
                child: Text(
                  state.errorMsg ?? 'Failed to load lyrics',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
