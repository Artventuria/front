import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:front/utils/constants.dart';

class CircularArtworkWidget extends StatelessWidget {
  final String imageName;
  final VoidCallback? onTap;

  const CircularArtworkWidget({
    super.key,
    required this.imageName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.circularGradientStart,
              AppColors.circularGradientEnd
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                imageName,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
