import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_details.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FeaturedEventItem extends StatefulWidget {
  final Event event;
  final bool isEnded;

  const FeaturedEventItem({
    super.key,
    required this.event,
    this.isEnded = false,
  });

  @override
  State<FeaturedEventItem> createState() => _FeaturedEventItemState();
}

class _FeaturedEventItemState extends State<FeaturedEventItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isActuallyEnded = widget.isEnded;
    if (widget.event.end_post_date != null &&
        widget.event.end_post_date!.isBefore(DateTime.now())) {
      isActuallyEnded = true;
    }

    final startDate = widget.event.start_post_date ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 48), // mb-12 -> 48px
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // gray-900
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F2937)), // gray-800
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Image with Gradients
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.event.image ?? '',
                  fit: BoxFit.cover,
                  color: isActuallyEnded
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.6),
                  colorBlendMode:
                      isActuallyEnded ? BlendMode.modulate : BlendMode.modulate,
                  imageBuilder: (context, imageProvider) => isActuallyEnded
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            // React has group-hover scale, we can just do subtle constant pulse or static for mobile
                            // Or no animation to mimic "hover"
                            return Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
                // Gradient right
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF111827), // gray-900
                        const Color(0xFF111827).withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Gradient bottom
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xFF111827),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(32), // p-8, md:p-12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActuallyEnded
                        ? const Color(0xFF374151)
                            .withOpacity(0.3) // gray-700/30
                        : const Color(0xFFDC2626)
                            .withOpacity(0.2), // red-600/20
                    border: Border.all(
                      color: isActuallyEnded
                          ? const Color(0xFF4B5563).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActuallyEnded
                              ? const Color(0xFF6B7280) // gray-500
                              : const Color(0xFFEF4444), // red-500
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActuallyEnded ? "Event Ended" : "Featured Event",
                        style: TextStyle(
                          color: isActuallyEnded
                              ? const Color(0xFF9CA3AF) // gray-400
                              : const Color(0xFFF87171), // red-400
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  widget.event.title ?? "Untitled Event",
                  style: TextStyle(
                    color: isActuallyEnded
                        ? const Color(0xFF9CA3AF) // gray-400
                        : Colors.white,
                    fontFamily: 'Manrope',
                    fontSize: 30, // text-3xl
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  widget.event.description ??
                      "Join us for this special event. Don't miss out on an incredible experience tailored just for you.",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB), // gray-300
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),

                // Info Badges
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildInfoBadge(
                      HugeIcons.strokeRoundedCalendar01,
                      DateFormat('EEEE, MMMM d').format(startDate),
                      isActuallyEnded,
                    ),
                    if (widget.event.location != null)
                      _buildInfoBadge(
                        HugeIcons.strokeRoundedLocation01,
                        widget.event.location!,
                        isActuallyEnded,
                      ),
                    _buildInfoBadge(
                      HugeIcons.strokeRoundedClock01,
                      DateFormat('h:mm a').format(startDate),
                      isActuallyEnded,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsPage(events: widget.event)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isActuallyEnded
                              ? const Color(0xFF1F2937) // gray-800
                              : const Color(0xFFDC2626), // red-600
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActuallyEnded
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFFDC2626)
                                        .withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isActuallyEnded
                                  ? "View Summary"
                                  : "Event Details",
                              style: TextStyle(
                                color: isActuallyEnded
                                    ? const Color(0xFF9CA3AF) // gray-400
                                    : Colors.white,
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              HugeIcons.strokeRoundedArrowRight01,
                              color: isActuallyEnded
                                  ? const Color(0xFF9CA3AF)
                                  : Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isActuallyEnded &&
                        widget.event.registration_url != null) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _launchUrl(widget.event.registration_url!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(
                            child: Text(
                              "Register Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, bool isEnded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isEnded
                ? const Color(0xFF6B7280) // gray-500
                : const Color(0xFFEF4444), // red-500
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFD1D5DB), // gray-300
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
