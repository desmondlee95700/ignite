import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/empty_state.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
import 'package:ignite/screens/event/event_item/home_event_item.dart';
import 'package:shimmer/shimmer.dart';

class HomeEventSection extends StatefulWidget {
  final EventBloc eventBloc;

  const HomeEventSection({
    super.key,
    required this.eventBloc,
  });

  @override
  State<HomeEventSection> createState() => _HomeEventSectionState();
}

class _HomeEventSectionState extends State<HomeEventSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        switch (state.status) {
          case EventStatus.initial:
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                enabled: true,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Container(
                      height: 200,
                      width: 150,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          case EventStatus.failure:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  EmptyState(
                    imageAsset: "assets/images/ignite_icon.jpg",
                    text: state.errorMsg ??
                        "Temporarily unable to load Ignite due to technical difficulties, please try again later...",
                  ),
                  state.retrying
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            widget.eventBloc.add(FetchEvent(
                              retrying: true,
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            margin: const EdgeInsets.all(10),
                            height: 35,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: kPrimaryColor,
                            ),
                            child: const Center(
                              child: Text(
                                "Retry",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          case EventStatus.success:
            List<Event> events = state.events;
            final limitedAnnouncements = events.take(3).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: limitedAnnouncements
                    .map(
                      (events) =>
                          HomeEventItem(events: events),
                    )
                    .toList(),
              ),
            );
        }
      },
    );
  }
}
