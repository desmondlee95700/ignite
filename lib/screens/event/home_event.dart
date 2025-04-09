import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/empty_state.dart';
import 'package:ignite/functions/size_config.dart';
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

            final ongoingEvents = events
                .where(
                    (event) => event.start_post_date!.isAfter(DateTime.now()))
                .toList();
            final endedEvents = events
                .where(
                    (event) => event.start_post_date!.isBefore(DateTime.now()))
                .toList();

            final limitedOngoingEvents = ongoingEvents.take(3).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      // Handle "View More Passed Event" click
                    },
                    child: const Text(
                      'On Going Event',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Manrope'),
                    ),
                  ),
                  Row(
                    children: limitedOngoingEvents
                        .map(
                          (event) => HomeEventItem(events: event),
                        )
                        .toList(),
                  ),
                  if (endedEvents.isNotEmpty) ...[
                    SizedBox(height: getProportionateScreenHeight(10)),
                    TextButton(
                      onPressed: () {
                        // Handle "View More Passed Event" click
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'View More Passed Event',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Manrope'),
                          ),
                          SizedBox(width: getProportionateScreenWidth(5)),
                          const Icon(
                            HugeIcons.strokeRoundedArrowRight01,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: endedEvents
                          .map(
                            (event) => HomeEventItem(events: event),
                          )
                          .toList(),
                    ),
                  ]
                ],
              ),
            );
        }
      },
    );
  }
}
