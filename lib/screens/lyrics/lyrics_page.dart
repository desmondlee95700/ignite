import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/lyrics/lyrics_bloc/lyrics_bloc.dart';
import 'package:ignite/screens/lyrics/pdf_viewer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/screens/settings/settings.dart';

class LyricsPage extends StatefulWidget {
  final ScrollController controller;

  const LyricsPage({super.key, required this.controller});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final LyricsBloc lyricsBloc = LyricsBloc(httpClient: http.Client());
  final TextEditingController searchController = TextEditingController();

  List<dynamic> filteredLyrics = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    lyricsBloc.add(FetchLyrics());
  }

  void openPDF(BuildContext context, String url, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingAnimationWidget.inkDrop(color: kPrimaryColor, size: 50);
      },
    );

    try {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: const Duration(milliseconds: 600),
            reverseDuration: const Duration(milliseconds: 600),
            isIos: true,
            opaque: true,
            child: PDFViewer(title: title, filePath: url),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }
  }

  void filterLyrics(String query, List<dynamic> allLyrics) {
    setState(() {
      searchQuery = query;
      filteredLyrics = allLyrics
          .where((lyric) =>
              lyric.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildHeader(List<dynamic> allLyrics) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: const Text(
                        'IGNITE // LYRICS',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    // Title
                    const Text(
                      'SONGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w900,
                        fontSize: 56, // Large display size
                        height: 0.9,
                        letterSpacing: -2.0,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                  icon: const Icon(HugeIcons.strokeRoundedSettings03,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Subtitle
            Text(
              'ACCESS THE COMPLETE WORSHIP COLLECTION.',
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(HugeIcons.strokeRoundedSearch01,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                      onChanged: (value) => filterLyrics(value, allLyrics),
                      decoration: const InputDecoration(
                        hintText: "SEARCH LYRICS...",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        isDense: true,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.grey, size: 20),
                        onPressed: () {
                          searchController.clear();
                          filterLyrics('', allLyrics);
                        }),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        controller: widget.controller,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              pinned: true,
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.black,
              toolbarHeight: 0,
              collapsedHeight: 0,
              expandedHeight: 0,
            ),
          ];
        },
        body: BlocProvider(
          create: (_) => lyricsBloc,
          child: BlocBuilder<LyricsBloc, LyricsState>(
            builder: (context, state) {
              if (state.status == LyricsStatus.initial) {
                return CustomScrollView(
                  slivers: [
                    _buildHeader([]),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 24),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          "SYNCING COLLECTION...",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade900,
                              highlightColor: Colors.grey.shade800,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                              ),
                            );
                          },
                          childCount: 6,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (state.status == LyricsStatus.success) {
                final allLyrics = state.lyrics;
                final displayLyrics =
                    searchQuery.isEmpty ? allLyrics : filteredLyrics;

                return RefreshIndicator.adaptive(
                  color: kPrimaryColor,
                  onRefresh: () async {
                    searchController.clear();
                    setState(() => searchQuery = '');
                    lyricsBloc.add(FetchLyrics(retrying: true));
                  },
                  child: CustomScrollView(
                    slivers: [
                      _buildHeader(allLyrics),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 24),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            searchQuery.isNotEmpty
                                ? "DETECTED ${displayLyrics.length} ENTRIES"
                                : "SHOWING: ${displayLyrics.length} LYRICS",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (displayLyrics.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final lyric = displayLyrics[index];
                                return InkWell(
                                  onTap: () {
                                    openPDF(
                                        context, lyric.pdf_url, lyric.title);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: lyric.image_url,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                  color: Colors.grey[900]),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                  color: Colors.grey[900],
                                                  child:
                                                      const Icon(Icons.error)),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black.withOpacity(0.9),
                                                  Colors.black.withOpacity(0.0),
                                                ],
                                                stops: const [0.0, 1.0],
                                              ),
                                            ),
                                            child: Text(
                                              lyric.title.toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Manrope',
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: displayLyrics.length,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 40),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                'NO ENTRIES FOUND FOR "$searchQuery"',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverPadding(
                          padding: EdgeInsets.only(bottom: 100)),
                    ],
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
      ),
    );
  }
}
