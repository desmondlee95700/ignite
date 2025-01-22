import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:ignite/screens/annoucement/annoucement_bloc/announcement_bloc.dart';
import 'package:ignite/screens/annoucement/home_annoucement.dart';
import 'package:ignite/screens/home/home_utils/home_appbar.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final ScrollController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      extendBodyBehindAppBar: true,
      //remove safe area for extend image behind appbar
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
            announcementBloc.add(FetchAnnouncement(
              retrying: true,
            ));
          },
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => announcementBloc),
            ],
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                left: 10,
                right: 10,
              ),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
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
                              SizedBox(width: getProportionateScreenWidth(10)),
                              const Icon(
                                HugeIcons.strokeRoundedMegaphone02,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: HomeAnnoucementSection(
                      announcementBloc: announcementBloc,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
