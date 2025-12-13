import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/model/Announcement.dart';
import 'package:ignite/screens/annoucement/annoucement_bloc/announcement_bloc.dart';
import 'package:ignite/screens/event/event_bloc/event_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final ScrollController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AnnouncementBloc _announcementBloc;
  late EventBloc _eventBloc;

  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _announcementBloc = AnnouncementBloc(httpClient: http.Client());
    _eventBloc = EventBloc(httpClient: http.Client());

    _announcementBloc.add(FetchAnnouncement());
    _eventBloc.add(FetchEvent());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _announcementBloc.close();
    _eventBloc.close();
    super.dispose();
  }

  // Helper to open URLs
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback or error handling
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size config might need init
    SizeConfig().init(context);

    // Dynamic Sizing based on width
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 380;

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.black,
        onRefresh: () async {
          _announcementBloc.add(FetchAnnouncement(retrying: true));
          _eventBloc.add(FetchEvent(retrying: true));
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _announcementBloc),
            BlocProvider.value(value: _eventBloc),
          ],
          child: CustomScrollView(
            controller: widget.controller,
            physics: const BouncingScrollPhysics(), // Native iOS feel
            slivers: [
              // Hero Section
              SliverToBoxAdapter(child: _buildHeroSection(isSmallScreen)),

              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // Tighter padding for mobile
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFeaturedEventSection(isSmallScreen),
                    const SizedBox(height: 32),
                    _buildBentoGrid(isSmallScreen),
                    const SizedBox(
                        height: 100), // Bottom padding for navigation bars
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isSmallScreen) {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.65, // Reduced height for mobile visibility
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with Overlay
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black12, Colors.black],
                stops: [0.3, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.darken,
            child: Image.asset(
              'assets/images/ignite_icon.jpg',
              errorBuilder: (c, o, s) => Container(color: Colors.grey[900]),
              fit: BoxFit.cover,
            ),
          ),

          // Grain/Texture overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.black],
              ),
            ),
          ),

          // Text Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'IGNITE',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 64 : 80, // Responsive text
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -3.0,
                        height: 0.9,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    decoration: const BoxDecoration(
                      border:
                          Border(left: BorderSide(color: Colors.red, width: 4)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'PASSION TO SEE PEOPLE\nIGNITED THROUGH THE\nENCOUNTER WITH GOD.',
                        style: TextStyle(
                          fontSize: 14, // Slightly smaller for reading
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.4,
                          letterSpacing: 1.1,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),

                  // Subtle Down Indicator
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Icon(Icons.arrow_downward_rounded,
                          color: Colors.white54, size: 24),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedEventSection(bool isSmallScreen) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state.status == EventStatus.initial ||
            (state.events.isEmpty && state.status == EventStatus.success)) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final events = state.events;

        // Logic from React: Valid events (not ended)
        final validEvents = events.where((e) {
          final end = e.end_post_date;
          return end != null && end.isAfter(now);
        }).toList();

        // Ongoing
        final ongoingEvents = validEvents.where((e) {
          final start = e.start_post_date;
          return start != null && start.isBefore(now);
        }).toList()
          ..sort((a, b) => (a.end_post_date ?? DateTime(0))
              .compareTo(b.end_post_date ?? DateTime(0)));

        // Future
        final futureEvents = validEvents.where((e) {
          final start = e.start_post_date;
          return start != null && start.isAfter(now);
        }).toList()
          ..sort((a, b) => (a.start_post_date ?? DateTime(0))
              .compareTo(b.start_post_date ?? DateTime(0)));

        if (ongoingEvents.isEmpty && futureEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        final featuredEvent =
            ongoingEvents.isNotEmpty ? ongoingEvents.first : futureEvents.first;
        final isOngoing = ongoingEvents.isNotEmpty;

        // Timer Logic
        _updateTimer(featuredEvent, isOngoing);

        // Render Featured Card
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              SizedBox(
                height: 380, // Optimized height
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: featuredEvent.image ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error)),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.0, 0.5],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOngoing
                              ? const Color(0xFFDC2626)
                              : Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          isOngoing ? 'HAPPENING NOW' : 'NEXT EVENT',
                          style: TextStyle(
                            color: isOngoing ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featuredEvent.title?.toUpperCase() ?? 'UNTITLED EVENT',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 0.9,
                        letterSpacing: -1.0,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white, thickness: 1),
                    const SizedBox(height: 20),

                    if (featuredEvent.start_post_date != null)
                      Row(
                        children: [
                          const Icon(HugeIcons.strokeRoundedCalendar01,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(featuredEvent.start_post_date!)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    if (featuredEvent.location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(HugeIcons.strokeRoundedLocation01,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              featuredEvent.location!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Countdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCountdownItem('DAYS', _timeLeft.inDays),
                          _buildCountdownItem('HRS', _timeLeft.inHours % 24),
                          _buildCountdownItem('MINS', _timeLeft.inMinutes % 60),
                          _buildCountdownItem('SECS', _timeLeft.inSeconds % 60),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Button
                    InkWell(
                      onTap: () {
                        // Navigate
                      },
                      child: Container(
                        height: 56, // Accessible height
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text(
                            'GET DETAILS',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateTimer(Event event, bool isOngoing) {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          final now = DateTime.now();
          final target =
              isOngoing ? event.end_post_date : event.start_post_date;
          if (target != null) {
            final diff = target.difference(now);
            _timeLeft = diff.isNegative ? Duration.zero : diff;
          }
        });
      });
    }
  }

  Widget _buildCountdownItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'Manrope',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'DISCOVER',
              style: TextStyle(
                  fontSize: isSmallScreen ? 36 : 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ARCHIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  )),
            )
          ],
        ),
        const SizedBox(height: 20),
        // Announcements
        BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            final announcements = state.announcements;
            if (announcements.isEmpty) return const SizedBox.shrink();

            final topAnnouncement = announcements.first;

            return Column(
              children: [
                // Large Card
                _buildAnnouncementCard(topAnnouncement,
                    isLarge: true, isSmallScreen: isSmallScreen),
                const SizedBox(height: 20),
                // Second Announcement
                if (announcements.length > 1)
                  _buildAnnouncementCard(announcements[1],
                      isLarge: false, isSmallScreen: isSmallScreen),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        // Events List (SCHEDULE)
        _buildSidebarEvents(isSmallScreen),
        const SizedBox(height: 20),
        // Join Movement
        _buildJoinMovementCard(),
      ],
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement,
      {required bool isLarge, required bool isSmallScreen}) {
    return Container(
      height: isLarge ? 400 : 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: announcement.image ?? '',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(isLarge ? 0.3 : 0.5),
            colorBlendMode: BlendMode.darken,
            placeholder: (context, url) => Container(color: Colors.grey[900]),
            errorWidget: (context, url, error) =>
                Container(color: Colors.grey[800]),
          ),
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLarge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Text(
                      'LATEST NEWS',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                Text(
                  announcement.title?.toUpperCase() ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLarge ? (isSmallScreen ? 28 : 32) : 22,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  announcement.description ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                if (isLarge)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Center(
                        child: Icon(Icons.arrow_forward,
                            color: Colors.white, size: 20)),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarEvents(bool isSmallScreen) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        final events = state.events.take(3).toList();
        if (events.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                child: const Row(
                  children: [
                    Icon(HugeIcons.strokeRoundedCalendar01,
                        color: Colors.red, size: 24),
                    SizedBox(width: 16),
                    Text('SCHEDULE',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white)),
                  ],
                ),
              ),
              const Divider(color: Colors.white, height: 1),
              ...events
                  .map((e) => Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Box
                                Container(
                                  width: 50,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          e.start_post_date?.day.toString() ??
                                              '',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 24)),
                                      Text(
                                          _getMonth(e.start_post_date)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title?.toUpperCase() ?? '',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            e.start_post_date != null
                                                ? _getTime(e.start_post_date!)
                                                : 'TBA',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 1),
                        ],
                      ))
                  .toList(),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FULL CALENDAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0)),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildJoinMovementCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(HugeIcons.strokeRoundedFire,
                color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'JOIN THE MOVEMENT',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'CONNECT ON SOCIAL MEDIA',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2.0,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialIcon(HugeIcons.strokeRoundedInstagram,
                    'https://www.instagram.com/ignite.fcc/'),
                const SizedBox(width: 32),
                _socialIcon(HugeIcons.strokeRoundedYoutube,
                    'https://www.youtube.com/@IgniteFCC/featured'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _getMonth(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[date.month - 1];
  }

  String _getTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
