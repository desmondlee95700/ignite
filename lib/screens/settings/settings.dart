import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/rate_dialog.dart';
import 'package:ignite/functions/size_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft02,
              size: 30), // Your custom icon here
          onPressed: () {
            Navigator.pop(context); // Pop the current screen
          },
        ),
      ),
      body: Column(
        children: [
          // ListTile(
          //   leading: Icon(
          //     AdaptiveTheme.of(context).theme ==
          //             AdaptiveTheme.of(context).darkTheme
          //         ? HugeIcons.strokeRoundedMoon02
          //         : HugeIcons.strokeRoundedSun03,
          //   ),
          //   title: const Text("Theme", style: TextStyle(fontSize: 16)),
          //   trailing: Switch.adaptive(
          //     activeColor: kPrimaryColor,
          //     value: AdaptiveTheme.of(context).theme ==
          //         AdaptiveTheme.of(context).darkTheme,
          //     onChanged: (value) {
          //       if (value) {
          //         AdaptiveTheme.of(context).setDark();
          //       } else {
          //         AdaptiveTheme.of(context).setLight();
          //       }
          //     },
          //   ),
          // ),
          // const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft, // Align to the left
            child: const Padding(
              padding:
                  EdgeInsets.only(left: 16), // Optional padding for spacing
              child: Text("Info",
                  style: TextStyle(fontSize: 18, fontFamily: 'Manrope')),
            ),
          ),
          ListTile(
            leading: const Icon(
              HugeIcons.strokeRoundedMessage01,
            ),
            title: const Text("Inquiries", style: TextStyle(fontSize: 16)),
            onTap: () async {
              // await launchUrl(
              //     Uri.parse(
              //         "https://www.google.com"),
              //     mode: LaunchMode.inAppBrowserView);
            },
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft, // Align to the left
            child: const Padding(
              padding:
                  EdgeInsets.only(left: 16), // Optional padding for spacing
              child: Text("App",
                  style: TextStyle(fontSize: 18, fontFamily: 'Manrope')),
            ),
          ),
          ListTile(
            leading: const Icon(
              HugeIcons.strokeRoundedStar,
            ),
            title: const Text("Rate App", style: TextStyle(fontSize: 16)),
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RateAppDialog(); // Show rate app dialog
                },
              );
            },
          ),
          const Spacer(),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(15),
              horizontal: getProportionateScreenWidth(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: getProportionateScreenHeight(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        String fbProtocolURL;
                        if (Platform.isIOS) {
                          fbProtocolURL = 'fb://profile/158038221526991';
                        } else {
                          fbProtocolURL = 'fb://page/158038221526991';
                        }
                        String fallbackUrl =
                            'https://www.facebook.com/158038221526991';
                        try {
                          Uri fbUri = Uri.parse(fbProtocolURL);
                          var canLaunchNatively = await canLaunchUrl(fbUri);
                          if (canLaunchNatively) {
                            launchUrl(fbUri);
                          } else {
                            await launchUrl(Uri.parse(fallbackUrl),
                                mode: LaunchMode.inAppBrowserView);
                          }
                        } catch (e, st) {
                          // Handle this as you prefer
                        }
                      },
                      child: const Icon(HugeIcons.strokeRoundedFacebook01,
                          color: Colors.blue, size: 30),
                    ),
                    SizedBox(width: getProportionateScreenWidth(20)),
                    InkWell(
                      onTap: () async {
                        String instaProtocolURL =
                            'https://www.instagram.com/ignite.fcc';
                        try {
                          Uri instaUri = Uri.parse(instaProtocolURL);
                          var canLaunchNatively = await canLaunchUrl(instaUri);
                          if (canLaunchNatively) {
                            launchUrl(instaUri);
                          } else {
                            await launchUrl(Uri.parse(instaProtocolURL),
                                mode: LaunchMode.inAppBrowserView);
                          }
                        } catch (e, st) {
                          // Handle this as you prefer
                        }
                      },
                      child: const Icon(HugeIcons.strokeRoundedInstagram,
                          color: Colors.pink, size: 30),
                    ),
                    SizedBox(width: getProportionateScreenWidth(20)),
                    InkWell(
                      onTap: () async {
                        String youtubeProtocolURL;
                        if (Platform.isIOS) {
                          youtubeProtocolURL =
                              'youtube://www.youtube.com/@IgniteFCC';
                        } else {
                          youtubeProtocolURL =
                              'https://www.youtube.com/@IgniteFCC';
                        }
                        String fallbackUrl =
                            'https://www.youtube.com/@IgniteFCC';
                        try {
                          Uri youtubeUri = Uri.parse(youtubeProtocolURL);
                          var canLaunchNatively =
                              await canLaunchUrl(youtubeUri);
                          if (canLaunchNatively) {
                            launchUrl(youtubeUri);
                          } else {
                            await launchUrl(Uri.parse(fallbackUrl),
                                mode: LaunchMode.inAppBrowserView);
                          }
                        } catch (e, st) {
                          // Handle this as you prefer
                        }
                      },
                      child: const Icon(HugeIcons.strokeRoundedYoutube,
                          color: Colors.red, size: 30),
                    ),
                    SizedBox(width: getProportionateScreenWidth(20)),
                    InkWell(
                      onTap: () async {
                        String tiktokProtocolURL =
                            'https://www.tiktok.com/@ignite.fcc';
                        try {
                          Uri tiktokUri = Uri.parse(tiktokProtocolURL);
                          var canLaunchNatively = await canLaunchUrl(tiktokUri);
                          if (canLaunchNatively) {
                            launchUrl(tiktokUri);
                          } else {
                            await launchUrl(Uri.parse(tiktokProtocolURL),
                                mode: LaunchMode.inAppBrowserView);
                          }
                        } catch (e, st) {
                          // Handle this as you prefer
                        }
                      },
                      child: Icon(HugeIcons.strokeRoundedNewTwitterRectangle,
                          color: AdaptiveTheme.of(context).theme ==
                                  AdaptiveTheme.of(context).darkTheme
                              ? Colors.white
                              : Colors.black,
                          size: 30),
                    ),
                    SizedBox(width: getProportionateScreenWidth(20)),
                    InkWell(
                      onTap: () async {
                        String spotifyProtocolURL =
                            'https://open.spotify.com/artist/0Cu1fBBJm6Rgmw0tQfrqsZ';
                        try {
                          Uri spotifyUri = Uri.parse(spotifyProtocolURL);
                          var canLaunchNatively =
                              await canLaunchUrl(spotifyUri);
                          if (canLaunchNatively) {
                            launchUrl(spotifyUri);
                          } else {
                            await launchUrl(Uri.parse(spotifyProtocolURL),
                                mode: LaunchMode.inAppBrowserView);
                          }
                        } catch (e, st) {}
                      },
                      child: const Icon(HugeIcons.strokeRoundedSpotify,
                          color: Colors.green, size: 30),
                    ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "A conference that driven by passionate to see people be ignited through the encounter with God.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AdaptiveTheme.of(context).theme ==
                            AdaptiveTheme.of(context).darkTheme
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(10)),
                Text(
                  "Version $buildNumber",
                  style: TextStyle(
                    fontSize: 12,
                    color: AdaptiveTheme.of(context).theme ==
                            AdaptiveTheme.of(context).darkTheme
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
