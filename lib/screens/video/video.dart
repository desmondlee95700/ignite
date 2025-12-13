import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ignite/model/MusicItem.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/video/musicitem_bloc/musicitem_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ignite/screens/settings/settings.dart';
import 'package:hugeicons/hugeicons.dart';

class MusicVideosPage extends StatefulWidget {
  final ScrollController? controller;

  const MusicVideosPage({super.key, this.controller});

  @override
  State<MusicVideosPage> createState() => _MusicVideosPageState();
}

class _MusicVideosPageState extends State<MusicVideosPage> {
  String _activeTab = 'video';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ... [Keep launchUrl and showUrlOptions helper methods - I will assume they are preserved if I don't target them]
  // WAIT: multi_replace targets specific lines. I need to be careful not to delete helpers.
  // The helpers are lines 34-155. I should NOT touch them.
  // So I will replace lines 18-32 (State def) and 157-227 (build).

  // Wait, I need to define the new variables.
  // I'll replace lines 18-32 First.
  /*
  class _MusicVideosPageState extends State<MusicVideosPage> {
    String _activeTab = 'video';
  */

  // Then replace the build method.

  Future<void> _launchUrl(MusicItem item) async {
    String? urlToLaunch;

    // Determine which URL to launch based on availability
    if (item.itemType == "video") {
      urlToLaunch = item.youtubeUrl;
    } else {
      // For songs, prioritize Spotify, fallback to YouTube
      urlToLaunch = item.spotifyUrl ?? item.youtubeUrl;
    }

    if (urlToLaunch == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No URL available for this item'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    final Uri url = Uri.parse(urlToLaunch);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not launch URL'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // Show bottom sheet to choose between Spotify and YouTube
  void _showUrlOptions(MusicItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Platform',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (item.spotifyUrl != null)
                ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.green),
                  title: const Text(
                    'Open in Spotify',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _launchSpecificUrl(item.spotifyUrl!);
                  },
                ),
              if (item.youtubeUrl != null)
                ListTile(
                  leading: const Icon(Icons.play_circle, color: Colors.red),
                  title: const Text(
                    'Open in YouTube',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _launchSpecificUrl(item.youtubeUrl!);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchSpecificUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not launch URL'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicItemBloc, MusicItemState>(
      builder: (context, state) {
        // Calculate counts
        final count = _activeTab == 'video'
            ? state.musicVideos.length
            : state.songs.length;

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            controller: widget.controller,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
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
                                  'IGNITE // MUSIC - SONGS',
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
                                'WATCH &\nLISTEN',
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
                      const SizedBox(height: 16),
                      Text(
                        'EXPERIENCE POWERFUL WORSHIP THROUGH OUR COLLECTION OF MUSIC VIDEOS AND SONGS.',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs (Pinned)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildTabItem('Music Videos', 'video'),
                            const SizedBox(width: 32),
                            _buildTabItem('Songs', 'song'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                            color: Colors.white.withOpacity(0.1), height: 1),
                        const SizedBox(height: 16),
                        Text(
                          'DISPLAYING $count ${_activeTab == 'video' ? 'VIDEOS' : 'TRACKS'}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  minHeight: 100, // Approx height of tab section
                  maxHeight: 100,
                ),
              ),

              // Content
              _buildSliverBody(state),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String label, String key) {
    final isActive = _activeTab == key;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = key),
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
              width:
                  40, // Or dynamic based on text width? React uses full width of text.
              color: const Color(0xFFEF4444),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildSliverBody(MusicItemState state) {
    if (state.status == MusicItemStatus.initial) {
      return SliverToBoxAdapter(
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: CircularProgressIndicator(color: Colors.grey[800]))),
      );
    }
    if (state.status == MusicItemStatus.failure) {
      //return SliverToBoxAdapter(child: _buildErrorState(state.errorMsg));
    }

    if (_activeTab == 'video') {
      return _buildVideoSliverGrid(state.musicVideos);
    } else {
      return _buildSongSliverList(state.songs);
    }
  }

  Widget _buildVideoSliverGrid(List<MusicItem> items) {
    if (items.isEmpty) return _buildSliverEmptyState('No videos found');

    // Sort logic
    final sortedItems = List<MusicItem>.from(items);
    sortedItems.sort((a, b) {
      if (a.isNewRelease && !b.isNewRelease) return -1;
      if (!a.isNewRelease && b.isNewRelease) return 1;
      final dateA = a.createdAt;
      final dateB = b.createdAt;
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMusicCard(sortedItems[index]),
          childCount: sortedItems.length,
        ),
      ),
    );
  }

  Widget _buildSongSliverList(List<MusicItem> items) {
    if (items.isEmpty) return _buildSliverEmptyState('No songs found');

    // Sort logic
    final sortedItems = List<MusicItem>.from(items);
    sortedItems.sort((a, b) {
      if (a.isNewRelease && !b.isNewRelease) return -1;
      if (!a.isNewRelease && b.isNewRelease) return 1;
      final dateA = a.createdAt;
      final dateB = b.createdAt;
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildMusicListItem(sortedItems[index]),
          childCount: sortedItems.length,
        ),
      ),
    );
  }

  Widget _buildSliverEmptyState(String message) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          message.toUpperCase(),
          style: TextStyle(color: Colors.grey[600], fontFamily: 'Manrope'),
        ),
      ),
    );
  }

  // Removed old Grid/List builders. The new _buildVideoSliverGrid and _buildSongSliverList (implemented in build block) replace them.
  // We'll keep the Item builders coming up next.

  Widget _buildMusicListItem(MusicItem item) {
    return GestureDetector(
      onTap: () => _launchUrl(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child:
                              const Icon(Icons.music_note, color: Colors.white),
                        );
                      },
                    ),
                    if (item.isNewRelease)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEW",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "LISTEN NOW",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.5,
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

  Widget _buildMusicCard(MusicItem item) {
    return GestureDetector(
      onTap: () => _launchUrl(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child:
                            const Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  ),
                  if (item.isNewRelease)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "NEW",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1),
                        ),
                      ),
                    ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "WATCH NOW",
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
