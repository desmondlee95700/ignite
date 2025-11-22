import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:ignite/screens/annoucement/annoucement_bloc/announcement_bloc.dart';
import 'package:ignite/screens/annoucement/home_annoucement.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
import 'package:ignite/screens/event/home_event.dart';
import 'package:ignite/screens/home/home_utils/home_appbar.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final ScrollController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final AnnouncementBloc announcementBloc =
      AnnouncementBloc(httpClient: http.Client());

  final EventBloc eventBloc = EventBloc(httpClient: http.Client());

  late AnimationController fadeController;
  late AnimationController slideController;
  late AnimationController scaleController;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    announcementBloc.add(FetchAnnouncement());
    eventBloc.add(FetchEvent());

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOut,
    ));
    slideController.forward();

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    scaleAnimation =
        Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeOutBack,
    ));
    scaleController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              delegate: SilverAppHomeBar(),
              pinned: true,
            ),
          ];
        },
        body: RefreshIndicator.adaptive(
          color: kPrimaryColor,
          onRefresh: () async {
            announcementBloc.add(FetchAnnouncement(retrying: true));
            eventBloc.add(FetchEvent(retrying: true));
          },
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => announcementBloc),
              BlocProvider(create: (_) => eventBloc),
            ],
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                left: 10,
                right: 10,
                bottom: kBottomNavigationBarHeight,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: BlocBuilder<EventBloc, EventState>(
                          builder: (context, state) {
                            String? title = state.title;
                            return Row(
                              children: [
                                Text(
                                  title ?? "Trending Events",
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                    width: getProportionateScreenWidth(10)),
                                Image.asset('assets/gif/trending_news_gif.gif',
                                    height: getProportionateScreenHeight(30),
                                    width: getProportionateScreenWidth(30)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                      child: SizedBox(height: getProportionateScreenHeight(5))),

                  // Slide In for Events Section
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: slideAnimation,
                      child: HomeEventSection(
                        eventBloc: eventBloc,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                      child:
                          SizedBox(height: getProportionateScreenHeight(20))),

                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
                          builder: (context, state) {
                            String? title = state.title;
                            return Row(
                              children: [
                                Text(
                                  title ?? "Hot Stuff",
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: getProportionateScreenWidth(5)),
                                Image.asset('assets/gif/megaphone_gif.gif',
                                    height: getProportionateScreenHeight(30),
                                    width: getProportionateScreenWidth(30)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                      child: SizedBox(height: getProportionateScreenHeight(5))),

                  // Slide In Animation
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: slideAnimation,
                      child: HomeAnnoucementSection(
                        announcementBloc: announcementBloc,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                      child:
                          SizedBox(height: getProportionateScreenHeight(20))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
