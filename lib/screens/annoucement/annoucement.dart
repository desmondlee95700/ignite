import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/screens/annoucement/annoucement_bloc/announcement_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ignite/screens/annoucement/annoucement_grid/announcement_grid.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnnoucementPage extends StatefulWidget {
  final ScrollController controller;

  const AnnoucementPage({Key? key, required this.controller}) : super(key: key);

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
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            floating: true,
            snap: true,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Text(
                  " | Annoucement",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      body: BlocProvider(
        create: (_) => announcementBloc,
        child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            if (state.status == AnnouncementStatus.initial) {
              return GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      const QuiltedGridTile(2, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                    left: 5,
                    right: 5,
                  ),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey,
                        ),
                      ),
                    );
                  });
            } else {
              List<Announcement> annoucements = state.announcements;
              String? errorMsg = state.errorMsg;

              return RefreshIndicator.adaptive(
                color: kPrimaryColor,
                onRefresh: () async {
                  announcementBloc.add(FetchAnnouncement(
                    retrying: true,
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top,
                    left: 5,
                    right: 5,
                  ),
                  child: CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverGrid.builder(
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: [
                            const QuiltedGridTile(2, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                          ],
                        ),
                        itemCount: annoucements.length,
                        itemBuilder: (context, index) {
                          final Announcement annoucement = annoucements[index];

                          return ExploreGridItem(
                            announcement: annoucement,
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: state.hasReachedMax
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  errorMsg ?? "You have reached the bottom",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
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
                                  padding: EdgeInsets.all(10.0),
                                  child: Center(
                                    child: CircularProgressIndicator.adaptive(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ), // Loading indicator
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
