import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../../models/artwork/artwork_model.dart';
import 'full_screen_artwork_page.dart';

class ArtworkScrollItem extends StatefulWidget {
  final String imageName;
  final String title;
  final String artist;
  final int year;
  final String location;
  final int points;
  final String description;
  final ArtworkModel? artwork;

  const ArtworkScrollItem({
    super.key,
    required this.imageName,
    required this.title,
    required this.artist,
    required this.year,
    required this.location,
    required this.points,
    required this.description,
    this.artwork,
  });

  @override
  State<ArtworkScrollItem> createState() => _ArtworkScrollItemState();
}

class _ArtworkScrollItemState extends State<ArtworkScrollItem> {
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1 / 1.5,
                child: Image.network(
                  widget.imageName,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withAlpha(128),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.fullscreen,
                        color: AppColors.white, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenArtworkPage(
                            imageName: widget.imageName,
                            title: widget.title,
                            artist: widget.artist,
                            year: widget.year,
                            isNetworkImage: widget.imageName.startsWith('http'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pointsBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.brush,
                          size: 14, color: AppColors.pointsColor),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.points} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointsColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.artist} · ${widget.year}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: AppColors.textLightGrey),
                const SizedBox(width: 4),
                Text(
                  widget.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightGrey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Button to access details
                if (widget.artwork != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8, top: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtworkDetailPage(artwork: widget.artwork!),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.purpleIndicator.withAlpha(40),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.purpleIndicator.withAlpha(180),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.viewDetails,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.purpleIndicator.withAlpha(180),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDarkGrey,
                  ),
                  maxLines: isDescriptionExpanded ? null : 1,
                  overflow: isDescriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (!isDescriptionExpanded)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isDescriptionExpanded = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.seeMore,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.purpleIndicator,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (isDescriptionExpanded)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isDescriptionExpanded = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppLocalizations.of(context)!.seeLess,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.purpleIndicator,
                          ),
                        ),
                      ),
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
