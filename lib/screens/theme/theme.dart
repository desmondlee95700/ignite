import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/screens/event/calendar_page.dart';
import 'package:page_transition/page_transition.dart';

class ThemePage extends StatefulWidget {
  final ScrollController controller;

  const ThemePage({Key? key, required this.controller}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> with TickerProviderStateMixin {
  final List<Map<String, String>> themes = [
    {
      'title': 'Ignite Chapel Worship',
      'image':
          'https://scontent.fkul10-1.fna.fbcdn.net/v/t39.30808-6/461948074_854002876876639_905622232010593494_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeEnlcH275VPy6Se3dMbjajn84tvN3x7UZPzi283fHtRk4vqJ6vzVXrFlSBXJvcxCOM&_nc_ohc=4irF4SoIF5MQ7kNvgH-L8YO&_nc_oc=AdjK4JsGIphZgFlKJST5XAfp7z0ZqucpJP86-RMuAvg8uF3UHgyR2N5pcpXsGFojzHPfyii6JoOcjvASjQsEr5xW&_nc_zt=23&_nc_ht=scontent.fkul10-1.fna&_nc_gid=AtTNr4VGAhoNVSEAvAQLGLi&oh=00_AYBXhyT-4Iqf9NcoLRgcST39Oo-duQGQND1aTaDOWoN8cQ&oe=67BBC183'
    },
    {
      'title': 'Kingdom',
      'image':
          'https://scontent.fkul15-1.fna.fbcdn.net/v/t39.30808-6/361907519_606999144910348_3444962530538038019_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_eui2=AeF3SqUaakDq7nv1J9ZnlM6k3jh38QWBzOPeOHfxBYHM45RqrZuovMr-mFp7GVnG3v4&_nc_ohc=aSl5v6yLJhgQ7kNvgGxJYFE&_nc_oc=AdiLwlAOGPSpFTQoxQoqglBHOaingNaypYbXxpnAkBDpwr8bCwdgm8TLuNJ2adksWoNe8Z5EGSmIMY4x0kcOWCS7&_nc_zt=23&_nc_ht=scontent.fkul15-1.fna&_nc_gid=AM-C3xUZM5WJwwl0_D4P_SI&oh=00_AYDUir2yH_3Q3I4Om6gIlWcQ1fU_Tr2_bq_XrfPFbivR2A&oe=67BBB27C'
    },
    {
      'title': 'Praise Party',
      'image':
          'https://scontent.fkul15-1.fna.fbcdn.net/v/t39.30808-6/476071786_1603377233659742_3876153975179527779_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=86c6b0&_nc_eui2=AeGgXtN6K38j9aYhQyhCbN7PlNhtKAt9iOaU2G0oC32I5jVe_ves2Moru-wYKw9bm3o&_nc_ohc=pdR48ZybiH0Q7kNvgGGS_Es&_nc_oc=Adh9uoW38PiescqVKeXmeacc-OiXiMB_c2NhYYMyCMngke5wy8hqHEDZNpAOGu17aHc2zdBUia4ySRkYGfNPWs_V&_nc_zt=23&_nc_ht=scontent.fkul15-1.fna&_nc_gid=AtxWYGaOSLO9sLQSLKJdzwQ&oh=00_AYCIG8TE56za8i2kXG-AfYdUSQzNPTSLzfYQp3ll3gSmtw&oe=67BB9DAD'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: widget.controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            floating: true,
            snap: true,
            surfaceTintColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  " | Ignite Themes",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                  ),
                ),             
              ],
            ),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: () {
                  // Handle theme selection
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: themes[index]['image']!,
                          imageBuilder: (context, imageProvider) => Container(
                            height: 200,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          placeholder: (context, url) {
                            return Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              height: 200,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/ignite_icon.jpg",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              themes[index]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Manrope',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
