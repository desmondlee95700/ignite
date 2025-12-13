import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
import 'package:ignite/screens/settings/settings.dart';

import 'package:shimmer/shimmer.dart';

import 'package:ignite/screens/event/event_item/home_event_item.dart';
import 'package:ignite/screens/event/event_item/featured_event_item.dart';

class EventsPage extends StatefulWidget {
  final ScrollController controller;

  const EventsPage({super.key, required this.controller});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String _searchQuery = "";
  String _activeFilter = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state.status == EventStatus.initial) {
            return _buildLoadingState();
          }

          final events = state.events;
          final filteredEvents = _filterEvents(events);
          final featuredEvent = _getFeaturedEvent(events);

          return CustomScrollView(
            controller: widget.controller,
            slivers: [
              _buildHeader(context),
              if (featuredEvent != null &&
                  _searchQuery.isEmpty &&
                  _activeFilter == "All")
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FeaturedEventItem(event: featuredEvent),
                  ),
                ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFilters(filteredEvents.length),
                      ],
                    ),
                  ),
                  minHeight: 70,
                  maxHeight: 70,
                ),
              ),
              _buildEventsGrid(filteredEvents),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
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
                        'IGNITE // EVENTS',
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
                      'HAPPENS',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w900,
                        fontSize: 56,
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
              'WORKSHOPS, GATHERINGS, AND SPECIAL OCCASIONS.',
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
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: "SEARCH EVENTS...",
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
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
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

  Widget _buildFilters(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar Style Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ["All", "Upcoming", "Ongoing", "Ended"].map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 32),
                child: _buildTabItem(filter, filter),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withOpacity(0.1), height: 1),
      ],
    );
  }

  Widget _buildTabItem(String label, String key) {
    final isActive = _activeFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = key),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isActive ? const Color(0xFFEF4444) : Colors.grey[500],
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              height: 2,
              width: 30, // Fixed width underline
              color: const Color(0xFFEF4444),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(height: 60, width: 250, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Full width skeletons
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade800,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white12),
                  ),
                ),
              ),
              childCount: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsGrid(List<Event> events) {
    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Text(
              "NO EVENTS FOUND",
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Manrope',
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // Responsive: 1 column on mobile, maybe 2 on larger (but for now simple 1 col listing or 2 col grid)
          // React code uses grid-cols-1 sm:grid-cols-2 lg:grid-cols-3
          crossAxisCount: 1, // Keep simple for mobile first, or maybe 2?
          // Let's stick to 1 for cards details visibility on mobile
          mainAxisSpacing: 16,
          childAspectRatio:
              0.75, // Adjusted to prevent overflow (more vertical space)
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => HomeEventItem(event: events[index]),
          childCount: events.length,
        ),
      ),
    );
  }

  Event? _getFeaturedEvent(List<Event> events) {
    if (events.isEmpty) return null;
    final now = DateTime.now();

    // Upcoming logic
    final upcoming = events
        .where(
            (e) => e.start_post_date != null && e.start_post_date!.isAfter(now))
        .toList()
      ..sort((a, b) => a.start_post_date!.compareTo(b.start_post_date!));

    if (upcoming.isNotEmpty) return upcoming.first;

    // Ongoing logic
    final ongoing = events
        .where((e) =>
            e.start_post_date != null &&
            e.end_post_date != null &&
            e.start_post_date!.isBefore(now) &&
            e.end_post_date!.isAfter(now))
        .toList();

    if (ongoing.isNotEmpty) return ongoing.first;

    // Most recent otherwise
    final sorted = List<Event>.from(events);
    sorted.sort((a, b) => (b.start_post_date ?? DateTime(0))
        .compareTo(a.start_post_date ?? DateTime(0)));

    return sorted.isNotEmpty ? sorted.first : null;
  }

  List<Event> _filterEvents(List<Event> events) {
    final now = DateTime.now();

    // Sort Newest first
    var result = List<Event>.from(events);
    result.sort((a, b) => (b.start_post_date ?? DateTime(0))
        .compareTo(a.start_post_date ?? DateTime(0)));

    // Status Filter
    if (_activeFilter != "All") {
      result = result.where((e) {
        final start = e.start_post_date;
        final end = e.end_post_date;
        if (start == null || end == null) return false;

        if (_activeFilter == "Upcoming") return start.isAfter(now);
        if (_activeFilter == "Ongoing") {
          return start.isBefore(now) && end.isAfter(now);
        }
        if (_activeFilter == "Ended") return end.isBefore(now);
        return true;
      }).toList();
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((e) {
        final title = e.title?.toLowerCase() ?? "";
        final desc = e.description?.toLowerCase() ?? "";
        final loc = e.location?.toLowerCase() ?? "";
        return title.contains(query) ||
            desc.contains(query) ||
            loc.contains(query);
      }).toList();
    }

    return result;
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyTabBarDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
