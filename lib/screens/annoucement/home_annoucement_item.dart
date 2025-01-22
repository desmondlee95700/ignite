import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ignite/model/Announcement.dart';

class HomeAnnoucementItem extends StatelessWidget {
  const HomeAnnoucementItem({
    super.key,
    required this.annoucements,
  });

  final Announcement annoucements;

  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            annoucements.image != null
                ? CachedNetworkImage(
                    imageUrl: annoucements.image!,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 200,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
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
                  )
                : Container(
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
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 75,
                width: 150,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  annoucements.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                    color: Colors.white,
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
