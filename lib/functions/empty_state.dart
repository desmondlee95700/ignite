import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String imageAsset;
  final String text;
  final IconData? bottomRightIcon;
  final Color? imageColor;
  final Color? iconColor;

  const EmptyState(
      {required this.imageAsset,
      required this.text,
      this.bottomRightIcon,
      this.imageColor,
      this.iconColor,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                imageAsset,
                height: 200,
                color: imageColor ??
                    (AdaptiveTheme.of(context).theme ==
                            AdaptiveTheme.of(context).darkTheme
                        ? Colors.white
                        : null),
              ),
              bottomRightIcon != null
                  ? Positioned(
                      bottom: 0,
                      right: 25,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (AdaptiveTheme.of(context).theme ==
                                  AdaptiveTheme.of(context).darkTheme
                              ? Colors.white
                              : Colors.black),
                        ),
                        child: Icon(
                          bottomRightIcon,
                          color: iconColor ??
                              (AdaptiveTheme.of(context).theme ==
                                      AdaptiveTheme.of(context).darkTheme
                                  ? Colors.black
                                  : Colors.white),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
