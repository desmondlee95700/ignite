import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
import 'package:ignite/screens/event/event_item/event_calendar_card.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final EventBloc eventBloc = EventBloc(httpClient: http.Client());

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    eventBloc.add(FetchEvent());
    _events = {};
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          " | Event",
          style: TextStyle(
            color: kPrimaryColor,
            fontFamily: 'Manrope',
            fontSize: 18,
          ),
        ),
        backgroundColor: darkThemeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedCircleArrowLeft02,
              size: 25, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocProvider(
        create: (_) => eventBloc,
        child: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            if (state.status == EventStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == EventStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMsg ?? "Something went wrong.",
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<EventBloc>()
                            .add(FetchEvent(retrying: true));
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            } else if (state.status == EventStatus.success) {
              // Build the event map for the calendar
              _events = _groupEventsByDate(state.events);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _buildYearDropdown()),
                        SizedBox(width: getProportionateScreenWidth(5)),
                        Expanded(child: _buildMonthDropdown()),
                      ],
                    ),
                  ),
                  TableCalendar(
                    pageAnimationCurve: Curves.bounceIn,
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    eventLoader: (day) {
                      final normalizedDay =
                          DateTime(day.year, day.month, day.day);
                      return _events[normalizedDay] ?? [];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = DateTime(
                          selectedDay.year,
                          selectedDay.month,
                          selectedDay.day,
                        );
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible:
                          false, // Hide the format button (optional)
                      titleTextStyle: TextStyle(
                        color: Colors.white, // White color for the month name
                        fontSize: 18,
                        fontFamily: "Manrope", // Adjust the size of the title
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        HugeIcons.strokeRoundedCircleArrowLeft01,
                        color: Colors.white, // Change color of the left arrow
                      ),
                      rightChevronIcon: Icon(
                        HugeIcons.strokeRoundedCircleArrowRight01,
                        color: Colors.white, // Change color of the right arrow
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: Colors.white, // White text for today
                      ),
                      defaultTextStyle: TextStyle(
                        color: Colors.grey, // White text for default days
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors
                            .black, // White text for weekend days (if needed)
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8.0),
                      children: (_events[_selectedDay] ?? []).isEmpty
                          ? [
                              const Center(
                                  child: Text(
                                "No events for this day.",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.bold),
                              ))
                            ]
                          : (_events[_selectedDay] ?? [])
                              .map((event) => EventCalendarCard(
                                    events: event,
                                  ))
                              .toList(),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text("Unexpected state."));
            }
          },
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        color: darkThemeColor,
      ),
      child: DropdownButtonFormField<int>(
        value: _focusedDay.year,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (newYear) {
          setState(() {
            _focusedDay = DateTime(newYear!, _focusedDay.month, 1);
            _selectedDay =
                DateTime(newYear, _focusedDay.month, _selectedDay?.day ?? 1);
          });
        },
        items: List.generate(11, (index) {
          int year = 2020 + index;
          return DropdownMenuItem(
            value: year,
            child: Text(
              year.toString(),
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Manrope"),
            ),
          );
        }),
        icon: const Icon(HugeIcons.strokeRoundedCircleArrowDown01,
            color: Colors.white),
        dropdownColor: darkThemeColor,
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        color: darkThemeColor,
      ),
      child: DropdownButtonFormField<int>(
        value: _focusedDay.month,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (newMonth) {
          setState(() {
            _focusedDay = DateTime(_focusedDay.year, newMonth!, 1);
            _selectedDay =
                DateTime(_focusedDay.year, newMonth, _selectedDay?.day ?? 1);
          });
        },
        items: List.generate(12, (index) {
          String monthName =
              DateFormat('MMMM').format(DateTime(2023, index + 1));
          return DropdownMenuItem(
            value: index + 1,
            child: Text(
              monthName,
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Manrope"),
            ),
          );
        }),
        icon: const Icon(HugeIcons.strokeRoundedCircleArrowDown01,
            color: Colors.white),
        dropdownColor: darkThemeColor,
      ),
    );
  }

  Map<DateTime, List<dynamic>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<dynamic>> groupedEvents = {};

    for (var event in events) {
      try {
        final eventDate = DateTime.parse(event.post_date!).toLocal();
        // Normalize the eventDate to remove the time part
        final normalizedEventDate =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (groupedEvents[normalizedEventDate] == null) {
          groupedEvents[normalizedEventDate] = [];
        }
        groupedEvents[normalizedEventDate]!.add(event);
      } catch (e) {
        print("Error parsing event date: ${event.post_date}, Error: $e");
      }
    }

    print("Grouped Events:");
    groupedEvents.forEach((key, value) {
      print("${key.toLocal().toIso8601String()} : ${value.length} events");
    });

    return groupedEvents;
  }
}
