import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import 'circular_artwork_widget.dart';

class RecentlyCollectedSection extends StatelessWidget {
  // TODO: For test, replace by API call
  final List<String> recentArtworks = [
    'Mona_Lisa,_by_Leonardo_da_Vinci,_from_C2RMF_natural_color.jpg.webp',
    'lanuitetoile.jpg',
    'le cri edward munch.jpg',
    'fille a la perle.jpg',
    'voyageur-devant-la-mer-de-nuages-oeuvres-dart (1).webp',
    'The_Great_Wave_off_Kanagawa-1024x706.jpg',
    'picasso-guernica.jpg',
    'LasMeninas.jpg',
    'magritte-painting-fils-de-l-homme.jpg',
    'le cri edward munch.jpg',
    'fille a la perle.jpg',
  ];

  RecentlyCollectedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppLocalizations.of(context)!.homePageRecentlyCollected,
            style: GoogleFonts.merriweather(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: AppColors.subtitlePink,
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 95,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: recentArtworks.length,
            itemBuilder: (context, index) {
              EdgeInsets padding;
              if (index == 0) {
                padding = const EdgeInsets.only(left: 20, right: 15);
              } else if (index == recentArtworks.length - 1) {
                padding = const EdgeInsets.only(right: 20);
              } else {
                padding = const EdgeInsets.only(right: 15);
              }

              return Padding(
                padding: padding,
                child: CircularArtworkWidget(
                  imageName: recentArtworks[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
