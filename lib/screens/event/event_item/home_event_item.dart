import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_details.dart';
import 'package:intl/intl.dart';

class HomeEventItem extends StatelessWidget {
  final Event event;

  const HomeEventItem({
    super.key,
    required this.event,
  });

  Map<String, dynamic> _getEventStatus() {
    final now = DateTime.now();
    final start = event.start_post_date ?? DateTime(0);
    final end = event.end_post_date ?? DateTime(0);

    if (now.isAfter(end)) {
      return {
        'label': 'Ended',
        'color': Colors.grey[600],
        'textColor': Colors.grey[200]
      };
    }
    if (now.isAfter(start) && now.isBefore(end)) {
      return {
        'label': 'Happening Now',
        'color': const Color(0xFF22C55E), // green-500
        'textColor': Colors.white
      };
    }
    return {
      'label': 'Upcoming',
      'color': const Color(0xFF2563EB), // blue-600
      'textColor': Colors.white
    };
  }

  @override
  Widget build(BuildContext context) {
    final status = _getEventStatus();
    final startDate = event.start_post_date ?? DateTime.now();
    final day = startDate.day.toString();
    final month = DateFormat('MMM').format(startDate);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventDetailsPage(events: event)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.4),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Container
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CachedNetworkImage(
                    imageUrl: event.image ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.error)),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.grey[900]!.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.4],
                      ),
                    ),
                  ),
                ),
                // Date Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minWidth: 60),
                    child: Column(
                      children: [
                        Text(
                          month.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFEF4444), // red-500
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          day,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status['color'],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      status['label'],
                      style: TextStyle(
                        color: status['textColor'],
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Info Rows
                    Column(
                      children: [
                        _buildInfoRow(
                          HugeIcons.strokeRoundedClock01,
                          DateFormat('EEEE, MMMM d, y').format(startDate),
                        ),
                        const SizedBox(height: 10),
                        if (event.location != null) ...[
                          _buildInfoRow(
                            HugeIcons.strokeRoundedLocation01,
                            event.location!,
                          ),
                          const SizedBox(height: 10),
                        ],
                        _buildInfoRow(
                          HugeIcons.strokeRoundedTicket01,
                          (event.price == null || event.price == 0)
                              ? 'Free Entry'
                              : 'RM ${event.price!.toStringAsFixed(2)}',
                          highlight: (event.price == null || event.price == 0),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Footer
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top:
                              BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'Manrope',
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool highlight = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.withOpacity(0.7), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: highlight ? Colors.green[400] : Colors.grey[400],
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: highlight ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
