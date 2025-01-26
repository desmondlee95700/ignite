import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/functions/datetime_helper.dart';
import 'package:ignite/model/Event.dart';
import 'package:typewritertext/typewritertext.dart';
import '../../functions/size_config.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({
    super.key,
    required this.events,
  });

  final Event events;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPage();
}

class _EventDetailsPage extends State<EventDetailsPage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation after a slight delay
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    // DO YOUR STUFF
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkThemeColor,
      body: Stack(
        children: <Widget>[
          // Container(
          //   decoration: const BoxDecoration(
          //       image: DecorationImage(
          //           image: AssetImage('assets/images/ignite_icon.jpg'),
          //           fit: BoxFit.fitWidth,
          //           alignment: Alignment.topCenter)),
          // ),
          CachedNetworkImage(
            imageUrl: widget.events.image!,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter),
              ),
            ),
            placeholder: (context, url) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/ignite_icon.jpg",
                      ),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter),
                ),
              );
            },
            errorWidget: (context, url, error) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/ignite_icon.jpg",
                      ),
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter),
                ),
              );
            },
          ),

          Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 300),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      color: darkThemeColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(
                                        HugeIcons
                                            .strokeRoundedCircleArrowLeft01,
                                        color: Colors.white,
                                        size: 30),
                                  ),
                                  SizedBox(
                                      width: getProportionateScreenWidth(10)),
                                  TypeWriter.text(
                                    "Ignite ${getYearFromDateString(widget.events.post_date.toString()).toString()}",
                                    maintainSize: false,
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 22,
                                        fontFamily: 'Manrope',
                                        color: Colors.red,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold),
                                    duration: const Duration(milliseconds: 150),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          AnimatedOpacity(
                            opacity: _isVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              transform: _isVisible
                                  ? Matrix4.identity()
                                  : Matrix4.translationValues(0, 50, 0)
                                ..scale(1.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 15, right: 8, left: 8),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              HugeIcons.strokeRoundedTag01,
                                              color: Colors.grey,
                                              size: 20),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      10)),
                                          const Text("RM 25.00",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            getProportionateScreenHeight(20)),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              HugeIcons.strokeRoundedLocation08,
                                              color: Colors.grey,
                                              size: 20),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      10)),
                                          const Text("Faith Chrisitan Centre",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            getProportionateScreenHeight(20)),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          const Icon(
                                              HugeIcons.strokeRoundedCalendar03,
                                              color: Colors.grey,
                                              size: 20),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      10)),
                                          Text(
                                              getDay(widget.events.post_date
                                                  .toString()),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      3)),
                                          Text(
                                              getMonthShort(widget
                                                  .events.post_date
                                                  .toString()),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      5)),
                                          const Text("-",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                          SizedBox(
                                              width:
                                                  getProportionateScreenWidth(
                                                      5)),
                                          Text(widget.events.time!,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Manrope",
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          HugeIcons
                                              .strokeRoundedInformationCircle,
                                          color: Colors.blue,
                                          size: 24),
                                      SizedBox(
                                          width:
                                              getProportionateScreenWidth(10)),
                                      Text(
                                        widget.events.title!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: getProportionateScreenHeight(15)),
                                  Text(
                                    "Join us for a blessed evening of worship and fellowship. Experience uplifting music, powerful sermons, and a warm community ready to welcome you with open arms.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Manrope',
                                      color: Colors.grey.shade300,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(30)),
                          SwipeButton(
                            thumbPadding: const EdgeInsets.all(5),
                            thumb: const Icon(
                              HugeIcons.strokeRoundedArrowRight01,
                              color: Colors.white,
                            ),
                            activeThumbColor: Colors.blue,
                            activeTrackColor: Colors.black,
                            elevationThumb: 2,
                            elevationTrack: 2,
                            child: const Text(
                              "Swipe to ...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onSwipe: () {},
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_swipe_button/flutter_swipe_button.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:ignite/functions/constant.dart';
// import 'package:ignite/functions/datetime_helper.dart';
// import 'package:ignite/functions/size_config.dart';
// import 'package:ignite/model/Event.dart';
// import 'package:ignite/screens/event/event_utils/event_details_appbar.dart';
// import 'package:typewritertext/typewritertext.dart';

// class EventDetailsPage extends StatefulWidget {
//   const EventDetailsPage({
//     super.key,
//     required this.events,
//   });

//   final Event events;

//   @override
//   State<EventDetailsPage> createState() => _EventDetailsPage();
// }

// class _EventDetailsPage extends State<EventDetailsPage> {
//   bool _isVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     // Trigger animation after a slight delay
//     Future.delayed(Duration(milliseconds: 300), () {
//       setState(() {
//         _isVisible = true;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // DO YOUR STUFF
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double topPadding = MediaQuery.of(context).padding.top + 10;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return <Widget>[
//             SliverPersistentHeader(
//               delegate: SilverEventDetailsAppBar(events: widget.events),
//               pinned: true,
//             ),
//           ];
//         },
//         body: Column(
//           children: <Widget>[
//             Expanded(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 margin: const EdgeInsets.only(top: 0),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//                         child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: TypeWriter.text(
//                               widget.events.title!,
//                               maintainSize: false,
//                               style: const TextStyle(
//                                   fontSize: 24,
//                                   fontFamily: 'Manrope',
//                                   color: Colors.red,
//                                   fontStyle: FontStyle.italic,
//                                   fontWeight: FontWeight.bold),
//                               duration: const Duration(milliseconds: 150),
//                             )),
//                       ),
//                       SizedBox(height: getProportionateScreenHeight(30)),
//                       AnimatedOpacity(
//                         opacity: _isVisible ? 1.0 : 0.0,
//                         duration: Duration(milliseconds: 800),
//                         child: AnimatedContainer(
//                           duration: Duration(milliseconds: 800),
//                           curve: Curves.easeInOut,
//                           transform: _isVisible
//                               ? Matrix4.identity()
//                               : Matrix4.translationValues(0, 50, 0)
//                             ..scale(1.0),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 spreadRadius: 0,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 15, bottom: 15, right: 8, left: 8),
//                             child: Column(
//                               children: [
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Row(
//                                     children: [
//                                       const Icon(HugeIcons.strokeRoundedTag01,
//                                           color: Colors.grey, size: 20),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(10)),
//                                       const Text("RM 25.00",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                     height: getProportionateScreenHeight(20)),
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Row(
//                                     children: [
//                                       const Icon(
//                                           HugeIcons.strokeRoundedLocation08,
//                                           color: Colors.grey,
//                                           size: 20),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(10)),
//                                       const Text("Faith Chrisitan Centre",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                     height: getProportionateScreenHeight(20)),
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Row(
//                                     children: [
//                                       const Icon(
//                                           HugeIcons.strokeRoundedCalendar03,
//                                           color: Colors.grey,
//                                           size: 20),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(10)),
//                                       Text(
//                                           getDay(widget.events.post_date
//                                               .toString()),
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(3)),
//                                       Text(
//                                           getMonthShort(widget.events.post_date
//                                               .toString()),
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(5)),
//                                       const Text("-",
//                                           style: TextStyle(
//                                               color: Colors.grey,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                       SizedBox(
//                                           width:
//                                               getProportionateScreenWidth(5)),
//                                       Text(widget.events.time!,
//                                           style: const TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: "Manrope",
//                                               fontSize: 14)),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: getProportionateScreenHeight(30)),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.1),
//                               spreadRadius: 0,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Icon(HugeIcons.strokeRoundedInformationCircle,
//                                       color: Colors.blue, size: 24),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     "Faith Christian Centre",
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontFamily: 'Manrope',
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 15),
//                               Text(
//                                 "Join us for a blessed evening of worship and fellowship. Experience uplifting music, powerful sermons, and a warm community ready to welcome you with open arms.",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontFamily: 'Manrope',
//                                   color: Colors.grey.shade300,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       SwipeButton(
//                         thumbPadding: const EdgeInsets.all(5),
//                         thumb: const Icon(
//                           HugeIcons.strokeRoundedArrowRight01,
//                           color: Colors.white,
//                         ),
//                         activeThumbColor: Colors.blue,
//                         activeTrackColor: Colors.black,
//                         elevationThumb: 2,
//                         elevationTrack: 2,
//                         child: const Text(
//                           "Swipe to ...",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontFamily: "Manrope",
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         onSwipe: () {},
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
