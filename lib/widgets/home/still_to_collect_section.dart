import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import 'artwork_grid_view.dart';
import 'artwork_scroll_view.dart';

class StillToCollectSection extends StatefulWidget {
  const StillToCollectSection({
    super.key,
  });

  @override
  State<StillToCollectSection> createState() => _StillToCollectSectionState();
}

class _StillToCollectSectionState extends State<StillToCollectSection> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.homePageStillToCollect,
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: AppColors.subtitlePink,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_agenda : Icons.grid_view,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        _isGridView ? const ArtworkGridView() : const ArtworkScrollView(),
      ],
    );
  }
}