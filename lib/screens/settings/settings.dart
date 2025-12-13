import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/rate_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    getBuildNumber();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getBuildNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      buildNumber = "${packageInfo.version}(${packageInfo.buildNumber})";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.black,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                "SETTINGS",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: 2.0,
                ),
              ),
              background: Container(color: Colors.black),
            ),
            leading: IconButton(
              icon: const Icon(HugeIcons.strokeRoundedArrowLeft01,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionHeader("INFO"),
                  _buildSettingsItem(
                    "INQUIRIES",
                    HugeIcons.strokeRoundedMessage01,
                    () async {
                      // await launchUrl(...)
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildSectionHeader("APP"),
                  _buildSettingsItem(
                    "RATE APP",
                    HugeIcons.strokeRoundedStar,
                    () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const RateAppDialog();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    "CONNECT WITH US",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _socialIcon(HugeIcons.strokeRoundedFacebook01,
                          'https://www.facebook.com/158038221526991'),
                      _socialIcon(HugeIcons.strokeRoundedInstagram,
                          'https://www.instagram.com/ignite.fcc'),
                      _socialIcon(HugeIcons.strokeRoundedYoutube,
                          'https://www.youtube.com/@IgniteFCC'),
                      _socialIcon(HugeIcons.strokeRoundedTiktok,
                          'https://www.tiktok.com/@ignite.fcc'),
                      _socialIcon(HugeIcons.strokeRoundedSpotify,
                          'https://open.spotify.com/artist/0Cu1fBBJm6Rgmw0tQfrqsZ'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "A conference driven by passion to see people ignited through an encounter with God.",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Version $buildNumber",
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Manrope',
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const Icon(HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
