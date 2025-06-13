import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/artwork/artwork_model.dart';
import '../../models/nfc/nfc_scan_result_model.dart';
import '../../providers/artwork_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/nfc_provider.dart';
import '../../providers/user_collection_provider.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../../services/storage/storage_service.dart';
import '../../utils/constants.dart';
import '../../widgets/nfc/pulse_animation.dart';

class NfcScanPage extends StatefulWidget {
  final StorageService? storageService;

  const NfcScanPage({super.key, this.storageService});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late NfcProvider _nfcProvider;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Initialize NFC provider
    _nfcProvider = NfcProvider();
    _nfcProvider.initializeService(widget.storageService);

    // Start NFC scan after the widget build is complete
    // to avoid context errors
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _startNfcScan();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nfcProvider.dispose();
    super.dispose();
  }

  /// Start the NFC scanning process
  Future<void> _startNfcScan() async {
    final localizations = AppLocalizations.of(context)!;

    await _nfcProvider.startNfcScan(
      iosMultipleTagMessage: localizations.nfcMultipleTagsDetected,
      iosAlertMessage: localizations.nfcScanningMessage,
      nfcNotAvailableMessage: localizations.nfcNotAvailable,
      nfcScanErrorMessage: localizations.nfcScanError,
      nfcScanSuccessfulMessage: localizations.nfcScanSuccessful,
      nfcArtworkAlreadyCollectedMessage:
          localizations.nfcArtworkAlreadyCollected,
      nfcUnknownStatusMessage: localizations.nfcUnknownStatus,
      nfcSessionCanceledMessage: localizations.nfcSessionCanceled,
    );

    // Update artwork provider if scan was successful
    if (_nfcProvider.scanResult?.status == NfcScanStatus.success &&
        _nfcProvider.scanResult?.artworkId != null) {
      final artworkProvider =
          Provider.of<ArtworkProvider>(context, listen: false);
      await artworkProvider
          .isArtworkInCollection(_nfcProvider.scanResult!.artworkId!);
    }
  }

  /// Try scanning again after an error
  Future<void> _retryScan() async {
    final localizations = AppLocalizations.of(context)!;

    await _nfcProvider.retryScan(
      iosMultipleTagMessage: localizations.nfcMultipleTagsDetected,
      iosAlertMessage: localizations.nfcScanningMessage,
      nfcNotAvailableMessage: localizations.nfcNotAvailable,
      nfcScanErrorMessage: localizations.nfcScanError,
      nfcScanSuccessfulMessage: localizations.nfcScanSuccessful,
      nfcArtworkAlreadyCollectedMessage:
          localizations.nfcArtworkAlreadyCollected,
      nfcUnknownStatusMessage: localizations.nfcUnknownStatus,
    );
  }

  /// Refresh all data and close the NFC page
  Future<void> _refreshAndExit() async {
    if (!mounted) return;

    final currentContext = context;
    final authProvider =
        Provider.of<AuthProvider>(currentContext, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      if (kDebugMode) {
        debugPrint('Refreshing all data before exiting the NFC page...');
      }
      try {
        final artworkProvider =
            Provider.of<ArtworkProvider>(currentContext, listen: false);
        final userCollectionProvider =
            Provider.of<UserCollectionProvider>(currentContext, listen: false);
        final leaderboardProvider =
            Provider.of<LeaderboardProvider>(currentContext, listen: false);
        final badgeProvider =
            Provider.of<BadgeProvider>(currentContext, listen: false);

        await Future.wait([
          artworkProvider.refreshAllData(userId),
          userCollectionProvider.refreshAllData(),
          leaderboardProvider.refreshLeaderboard(),
          badgeProvider.loadUserBadges(forceReload: true),
        ]);
        if (kDebugMode) {
          debugPrint("NFC Page: All data refreshed.");
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Error refreshing data: $e");
        }
      }
    }

    if (mounted && Navigator.of(currentContext).canPop()) {
      Navigator.of(currentContext).pop();
    }
  }

  /// Navigate to the detail page and refresh data on return
  Future<void> _viewArtworkAndRefreshOnReturn() async {
    final scanResult = _nfcProvider.scanResult;

    if (scanResult?.artworkData == null ||
        scanResult!.artworkData!['artwork'] == null) {
      debugPrint("Artwork data not available for navigation.");
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.errorLoadingArtworks)));
      }
      return;
    }

    final artwork = ArtworkModel.fromJson(scanResult.artworkData!['artwork']);
    final currentContext = context;
    if (!mounted) return;

    await Navigator.of(currentContext).push(
      MaterialPageRoute(builder: (ctx) => ArtworkDetailPage(artwork: artwork)),
    );

    // After returning, refresh everything and exit
    await _refreshAndExit();
  }

  /// Build the scan result content (success, error, already collected)
  Widget _buildScanResultContent(
      BuildContext context, AppLocalizations localizations) {
    final scanResult = _nfcProvider.scanResult;
    if (scanResult == null) return const SizedBox.shrink();

    // Content for success and already collected states (unified UI)
    if (_nfcProvider.scanState == NfcScanStatus.success ||
        _nfcProvider.scanState == NfcScanStatus.alreadyCollected) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message ('Scan successful' or 'Already collected')
          Text(
            scanResult.message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.purpleIndicator,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Artwork title and artist
          if (scanResult.artworkTitle?.isNotEmpty == true) ...[
            Text(
              scanResult.artworkTitle!,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (scanResult.artworkArtist?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(scanResult.artworkArtist!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
          ],

          // Points earned (only if success)
          if (_nfcProvider.scanState == NfcScanStatus.success &&
              scanResult.pointsEarned?.isNotEmpty == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.subtitlePink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.subtitlePink, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.brush,
                      color: AppColors.subtitlePink, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '${scanResult.pointsEarned} ${localizations.points}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.subtitlePink,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),

          // View artwork button
          if (scanResult.artworkId?.isNotEmpty == true) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _viewArtworkAndRefreshOnReturn,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      backgroundColor: AppColors.purpleIndicator,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(localizations.viewArtworkButton),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Confirm button
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _refreshAndExit,
                  child: Text(
                    localizations.confirm,
                    style: const TextStyle(color: AppColors.standardGrey),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
    // Error state content
    else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error message
          Text(
            scanResult.message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.purpleIndicator,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Retry button
          ElevatedButton(
            onPressed: _retryScan,
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.purpleIndicator,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(localizations.retryButton),
          ),

          const SizedBox(height: 16),

          // Confirm button (back) - Uses Navigator.maybePop for WillPopScope
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(localizations.confirm),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _nfcProvider,
      child: Consumer<NfcProvider>(builder: (context, nfcProvider, child) {
        return WillPopScope(
          onWillPop: () async {
          if (nfcProvider.scanState == NfcScanStatus.success ||
              nfcProvider.scanState == NfcScanStatus.alreadyCollected) {
            await _refreshAndExit(); // Handle the pop and refresh
            return false; // Indicate that the pop has been handled
          } else if (nfcProvider.scanState == NfcScanStatus.scanning) {
            await nfcProvider.stopNfcScan();
            return true; // Allow the pop after stopping the NFC scan
          }
          return true; // Allow the pop for other states (error, canceled, etc.)
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.standardGrey),
                onPressed: () {
                  // Let WillPopScope handle the pop and refresh logic
                  Navigator.of(context).maybePop();
                },
              ),
              title: Text(
                localizations.nfcScanTitle,
                style: const TextStyle(color: AppColors.standardGrey),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    if (nfcProvider.scanState == NfcScanStatus.scanning) ...[
                      const SizedBox(
                        height: 200,
                        width: 200,
                        child: PulseAnimation(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.nfcScanningInstructions,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.standardGrey,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ] else if (nfcProvider.scanState == NfcScanStatus.success ||
                      nfcProvider.scanState == NfcScanStatus.error ||
                      nfcProvider.scanState == NfcScanStatus.canceled ||
                      nfcProvider.scanState ==
                          NfcScanStatus.alreadyCollected) ...[
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child:
                                _buildScanResultContent(context, localizations),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
