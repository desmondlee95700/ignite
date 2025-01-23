import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BackgroundEventWave extends StatelessWidget {
  final double height;
  final String? backgroundImage;

  const BackgroundEventWave(
      {super.key, required this.height, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipPath(
        clipper: BackgroundWaveClipper(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipPath(
                clipper: BackgroundWaveClipper(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: height,
                  child: backgroundImage != null
                      ? CachedNetworkImage(
                          imageUrl: backgroundImage!,
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/images/ignite_icon.jpg",
                            fit: BoxFit.cover,
                          ),
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/ignite_icon.jpg",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    double clipHeight = 200;

    // Start from the top left corner
    path.lineTo(0.0, 0.0);

    // Draw a straight line to the top right corner
    path.lineTo(size.width, 0.0);

    // Draw a straight line to the bottom right corner,
    // leaving out the bottom 80 pixels
    path.lineTo(size.width, clipHeight);

    // Draw a straight line to the bottom left corner,
    // leaving out the bottom 80 pixels
    path.lineTo(0.0, clipHeight);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(BackgroundWaveClipper oldClipper) => oldClipper != this;
}
