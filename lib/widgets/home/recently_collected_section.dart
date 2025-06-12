import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';
import '../../providers/artwork_provider.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../../screens/nfc/nfc_scan_page.dart';
import 'circular_artwork_widget.dart';
import 'nfc_scan_button.dart';

class RecentlyCollectedSection extends StatefulWidget {
  const RecentlyCollectedSection({super.key});

  @override
  State<RecentlyCollectedSection> createState() =>
      _RecentlyCollectedSectionState();
}

class _RecentlyCollectedSectionState extends State<RecentlyCollectedSection> {
  @override
  void initState() {
    super.initState();
    // Load recently collected artworks after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        final artworkProvider =
            Provider.of<ArtworkProvider>(context, listen: false);
        artworkProvider.loadRecentlyCollectedArtworks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final artworkProvider = Provider.of<ArtworkProvider>(context);
    final artworks = artworkProvider.recentlyCollectedArtworks;

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
        // Always show a horizontal line, even if no artworks
        SizedBox(
          height: 95,
          child: !artworkProvider.isLoadingRecentlyCollected &&
                  !artworkProvider.hasErrorRecentlyCollected &&
                  artworks.isEmpty
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // NFC Scan button always visible
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 15),
                      child: NfcScanButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NfcScanPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    // Message "No recent artworks" next to the button
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.noRecentArtworks,
                          style: const TextStyle(color: AppColors.standardGrey),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Right margin
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: artworks.length + 1, // +1 for the NFC scan button
                  itemBuilder: (context, index) {
                    EdgeInsets padding;

                    if (index == 0) {
                      // NFC Scan button (first item)
                      padding = const EdgeInsets.only(left: 20, right: 15);
                      return Padding(
                        padding: padding,
                        child: NfcScanButton(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NfcScanPage(),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      // Actual artwork items (index - 1 because of the NFC button)
                      final artworkIndex = index - 1;
                      if (artworkIndex == 0) {
                        padding = const EdgeInsets.only(right: 15);
                      } else if (artworkIndex == artworks.length - 1) {
                        padding = const EdgeInsets.only(right: 20);
                      } else {
                        padding = const EdgeInsets.only(right: 15);
                      }

                      final artwork = artworks[artworkIndex];

                      return Padding(
                        padding: padding,
                        child: CircularArtworkWidget(
                          imageName: artwork.metadata.imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArtworkDetailPage(artwork: artwork),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}
