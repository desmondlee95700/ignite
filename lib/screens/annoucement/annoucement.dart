import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/screens/annoucement/annoucement_bloc/announcement_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/screens/annoucement/annoucement_grid/announcement_grid.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:hugeicons/hugeicons.dart';

class AnnoucementPage extends StatefulWidget {
  final ScrollController controller;

  const AnnoucementPage({super.key, required this.controller});

  @override
  State<AnnoucementPage> createState() => _AnnoucementPageState();
}

class _AnnoucementPageState extends State<AnnoucementPage> {
  final AnnouncementBloc announcementBloc =
      AnnouncementBloc(httpClient: http.Client());

  @override
  void initState() {
    announcementBloc.add(FetchAnnouncement());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              toolbarHeight:
                  0, // Hide default toolbar content, just status bar area
              collapsedHeight: 0,
              expandedHeight: 0,
            ),
          ];
        },
        body: BlocProvider(
          create: (_) => announcementBloc,
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
            builder: (context, state) {
              // Loading State
              if (state.status == AnnouncementStatus.initial) {
                return CustomScrollView(
                  slivers: [
                    _buildHeader(0, true),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade900,
                              highlightColor: Colors.grey.shade800,
                              child: Container(
                                height: 140,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Container(width: 140, color: Colors.black),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 20,
                                                width: double.infinity,
                                                color: Colors.grey[800]),
                                            const SizedBox(height: 8),
                                            Container(
                                                height: 14,
                                                width: 150,
                                                color: Colors.grey[800]),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
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
              } else {
                // Success/Failure State
                List<Announcement> annoucements = state.announcements;

                return RefreshIndicator.adaptive(
                  color: kPrimaryColor,
                  onRefresh: () async {
                    announcementBloc.add(FetchAnnouncement(retrying: true));
                  },
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      _buildHeader(annoucements.length, false),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ExploreGridItem(
                                announcement: annoucements[index],
                              );
                            },
                            childCount: annoucements.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: state.hasReachedMax
                            ? Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Text(
                                  "END OF FEED",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Manrope',
                                    letterSpacing: 2.0,
                                  ),
                                ))
                            : VisibilityDetector(
                                key: const Key('load-more'),
                                onVisibilityChanged: (visibilityInfo) {
                                  var visiblePercentage =
                                      visibilityInfo.visibleFraction * 100;
                                  if (visiblePercentage > 95) {
                                    announcementBloc.add(FetchAnnouncement(
                                      retrying: false,
                                    ));
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
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
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count, bool loading) {
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
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: const Text(
                        'IGNITE // ANNOUNCEMENTS',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Text(
                      'UPDATES',
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
            Text(
              'LATEST NEWS, VIDEOS, AND HIGHLIGHTS FROM THE COMMUNITY.',
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loading ? 'SYNCING FEED...' : 'FEED: $count POSTS',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
