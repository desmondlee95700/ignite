// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ignite/functions/constant.dart';
// import 'package:ignite/model/Event.dart';
// import 'package:page_transition/page_transition.dart';

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
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // DO YOUR STUFF
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: <Widget>[
//           // Container(
//           //   decoration: const BoxDecoration(
//           //       image: DecorationImage(
//           //           image: AssetImage('assets/images/ignite_icon.jpg'),
//           //           fit: BoxFit.fitWidth,
//           //           alignment: Alignment.topCenter)),
//           // ),
//           CachedNetworkImage(
//             imageUrl: widget.events.image!,
//             imageBuilder: (context, imageProvider) => Container(
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(16),
//                 image: DecorationImage(
//                     image: imageProvider,
//                     fit: BoxFit.fitWidth,
//                     alignment: Alignment.topCenter),
//               ),
//             ),
//             placeholder: (context, url) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(16),
//                   image: const DecorationImage(
//                       image: AssetImage(
//                         "assets/images/ignite_icon.jpg",
//                       ),
//                       fit: BoxFit.fill,
//                       alignment: Alignment.topCenter),
//                 ),
//               );
//             },
//             errorWidget: (context, url, error) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(16),
//                   image: const DecorationImage(
//                       image: AssetImage(
//                         "assets/images/ignite_icon.jpg",
//                       ),
//                       fit: BoxFit.fill,
//                       alignment: Alignment.topCenter),
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             top: 40, // Adjusted vertical positioning for visibility
//             left: 16, // Adjusted horizontal positioning
//             child: GestureDetector(
//               onTap: () {
//                 print("Logged Back button tapped");
//                 Navigator.pop(context); // Handle back navigation
//               },
//               child: Material(
//                 color: Colors
//                     .transparent, // Ensures InkWell ripple effect is visible
//                 child: InkWell(
//                   onTap: () {
//                     print("Back button tapped via InkWell");
//                     Navigator.pop(context);
//                   },
//                   borderRadius: BorderRadius.circular(
//                       20), // Ripple area matches container shape
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(
//                           0.8), // Higher opacity for better contrast
//                       shape: BoxShape.circle,
//                     ),
//                     padding:
//                         const EdgeInsets.all(8), // Padding for the icon size
//                     child: const Icon(
//                       Icons.arrow_back, // Back arrow icon
//                       color: Colors.white, // Icon color
//                       size: 24, // Adjust size if needed
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           Column(
//             children: <Widget>[
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     margin: const EdgeInsets.only(top: 300),
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                         bottomLeft: Radius.zero,
//                         bottomRight: Radius.zero,
//                       ),
//                       color: Colors.white,
//                     ),
//                     child: const Padding(
//                       padding: EdgeInsets.all(23),
//                       child: Column(
//                         children: <Widget>[
//                           Padding(
//                             padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
//                             child: Text(
//                               "MyTrust ID",
//                               style: TextStyle(fontSize: 20),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ignite/functions/constant.dart';
import 'package:ignite/model/Event.dart';
import 'package:ignite/screens/event/event_utils/event_details_appbar.dart';
import 'package:ignite/screens/home/home_utils/background_wave.dart';
import 'package:page_transition/page_transition.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // DO YOUR STUFF
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      extendBodyBehindAppBar: true,
      //remove safe area for extend image behind appbar
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              delegate: SilverEventDetailsAppBar(events: widget.events),
              pinned: true,
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 0),
                  child: const Padding(
                    padding: EdgeInsets.all(23),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Text(
                            "MyTrust ID",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
