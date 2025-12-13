import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/model/Event.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsPage extends StatefulWidget {
  final Event events;

  const EventDetailsPage({super.key, required this.events});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  String? _selectedImage;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  void _openMap(String location) {
    // Platform specific map opening could be better but simple web url works for now
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}';
    _launchUrl(mapsUrl);
  }

  bool _isEventExpired() {
    final end = widget.events.end_post_date;
    if (end == null) return false;
    return DateTime.now().isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedImage != null) {
      return _buildLightbox(context);
    }

    final isExpired = _isEventExpired();
    // Assuming schedule_image is List<String> based on previous context,
    // but the Model might define it as dynamic or List<String>.
    // Safely handling it.
    List<String> scheduleImages = widget.events.schedule_image ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Cinematic Hero Background
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.events.image ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900], child: const Icon(Icons.error)),
                ),
                // Gradients
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                // Hero Content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.grey
                                    : const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isExpired ? "EVENT ENDED" : "REGISTRATION OPEN",
                              style: const TextStyle(
                                color: Color(0xFFF87171),
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.events.title?.toUpperCase() ?? "UNTITLED EVENT",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Manrope',
                          fontSize: 48, // Large Cinematic Title
                          fontWeight: FontWeight.w900,
                          height: 0.9,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Date & Location Row
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(HugeIcons.strokeRoundedCalendar01,
                                  color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _formatDateRange(widget.events.start_post_date,
                                    widget.events.end_post_date),
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (widget.events.location != null)
                            GestureDetector(
                              onTap: () => _openMap(widget.events.location!),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(HugeIcons.strokeRoundedLocation01,
                                      color: Color(0xFFEF4444), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.events.location!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Manrope',
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.grey,
                                      decorationStyle:
                                          TextDecorationStyle.dotted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content Grid
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  child: Column(
                    children: [
                      // 1. Quick Stats (Bento Row)
                      Row(
                        children: [
                          Expanded(
                              child: _buildBentoStat(
                                  HugeIcons.strokeRoundedTime01,
                                  "TIME",
                                  _formatTime(widget.events.start_post_date),
                                  Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildBentoStat(
                                  HugeIcons.strokeRoundedMoney02,
                                  "PRICE",
                                  (widget.events.price == null ||
                                          widget.events.price == 0)
                                      ? "Free"
                                      : "RM${widget.events.price}",
                                  Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBentoStat(HugeIcons.strokeRoundedUserCircle,
                          "EXPERIENCE", "Live In-Person", Colors.purple,
                          fullWidth: true),
                      const SizedBox(height: 32),

                      // 2. About
                      if (widget.events.description != null) ...[
                        _buildSectionTitle(
                            HugeIcons.strokeRoundedFile01, "About The Event"),
                        const SizedBox(height: 16),
                        Text(
                          widget.events.description!,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],

                      // 3. Schedule
                      if (scheduleImages.isNotEmpty) ...[
                        _buildSectionTitle(HugeIcons.strokeRoundedCalendar03,
                            "Event Schedule"),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: scheduleImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => setState(() =>
                                    _selectedImage = scheduleImages[index]),
                                child: Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          scheduleImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2)),
                                      ),
                                      child: const Text(
                                        "Tap to Enlarge",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Manrope',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],

                      // 4. Ticket Card (Sticky-like feel at bottom of content)
                      _buildDigitalTicket(context, isExpired),

                      const SizedBox(height: 48),
                      // Support
                      Text(
                        "Questions about this event?",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Manrope',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            _launchUrl('mailto:igniteconference.fcc@gmail.com'),
                        child: const Text(
                          "Contact Support",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back Button (Fixed)
          Positioned(
            top: 60,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(HugeIcons.strokeRoundedArrowLeft01,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLightbox(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: _selectedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 24,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStat(
      IconData icon, String label, String value, Color iconColor,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B).withOpacity(0.8), // zinc-900/80
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Manrope',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalTicket(BuildContext context, bool isExpired) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 50,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Part
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F5), // zinc-100
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "REGISTRATION",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.events.title ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Dashed rows
                _buildTicketRow(
                    "Date", _formatDateSimple(widget.events.start_post_date)),
                _buildTicketRow(
                    "Cost",
                    (widget.events.price == null || widget.events.price == 0)
                        ? "FREE"
                        : "RM${widget.events.price}"),
              ],
            ),
          ),
          // Divider with circles
          Stack(
            children: [
              Container(height: 1, color: const Color(0xFFF4F4F5)), // filler
              Container(
                height: 20,
                color: const Color(0xFFF4F4F5),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.horizontal(right: Radius.circular(12)),
                      ),
                    ),
                    Expanded(
                      child: CustomPaint(
                        painter: DashedLinePainter(),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bottom Part
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA), // zinc-50
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: isExpired
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Event has ended",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      if (widget.events.registration_url != null)
                        _buildActionButton(
                          "Register Now",
                          HugeIcons.strokeRoundedRegister,
                          Colors.black,
                          Colors.white,
                          () => _launchUrl(widget.events.registration_url!),
                        ),
                      if (widget.events.registration_url != null &&
                          widget.events.payment_url != null)
                        const SizedBox(height: 12),
                      if (widget.events.payment_url != null)
                        _buildActionButton(
                          (widget.events.price == null ||
                                  widget.events.price == 0)
                              ? "Get Free Pass"
                              : "Pay Online",
                          HugeIcons.strokeRoundedCards01,
                          widget.events.registration_url == null
                              ? Colors.black
                              : Colors.white,
                          widget.events.registration_url == null
                              ? Colors.white
                              : Colors.black,
                          () => _launchUrl(widget.events.payment_url!),
                          outlined: widget.events.registration_url != null,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        "Secure registration powered by Google Forms.",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Manrope',
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
            style: BorderStyle.solid, // Dashed unsupported in standard border
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color bg, Color text, VoidCallback onTap,
      {bool outlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: text, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: text,
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return "Unknown Date";
    final startStr = DateFormat('MMMM d, y').format(start);
    if (end != null && end != start) {
      final endStr = DateFormat('MMMM d, y').format(end);
      return "$startStr - $endStr";
    }
    return startStr;
  }

  String _formatDateSimple(DateTime? date) {
    if (date == null) return "";
    return DateFormat('MMM d').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";
    return DateFormat('h:mm a').format(date);
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
