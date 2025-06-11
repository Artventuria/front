import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/artwork/artwork_model.dart';
import '../../providers/artwork_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/user_collection_provider.dart';
import '../../screens/artwork/artwork_detail_page.dart';
import '../../services/api/api_service.dart';
import '../../services/storage/storage_service.dart';
import '../../utils/constants.dart';
import '../../widgets/nfc/pulse_animation.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Define the possible states during NFC scanning
enum NfcScanState { scanning, success, error, notSupported, alreadyCollected }

class NfcScanPage extends StatefulWidget {
  final StorageService? storageService;

  const NfcScanPage({super.key, this.storageService});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage>
    with TickerProviderStateMixin {
  // Scanning state
  NfcScanState _scanState = NfcScanState.scanning;
  // Message to display according to the scan state
  String _scanMessage = '';
  String _pointsEarned = '';

  // Informations about the scanned artwork
  String _artworkTitle = '';
  String _artworkArtist = '';
  // _artworkData is stored during API calls and used indirectly to extract
  // the values of _artworkTitle and _artworkArtist in _showSuccessMessage and _showErrorMessage
  Map<String, dynamic>? _artworkData;

  late AnimationController _animationController;
  ApiService? _apiService;
  String? _artworkId;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Start animation without waiting
    _animationController.repeat();

    // Initialize API and start scan after the widget build is complete
    // to avoid context errors
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // If we already have the service as a parameter, we use it
      if (widget.storageService != null) {
        _apiService = ApiService(widget.storageService!);
        _startNfcScan();
        return;
      }

      // Otherwise, we try to retrieve it via an alternative solution
      try {
        // Solution 1: via the global provider (may fail depending on the context)
        try {
          final storageService =
              Provider.of<StorageService>(context, listen: false);
          _apiService = ApiService(storageService);
        } catch (e) {
          // Solution 2: create a new instance (always works)
          _apiService = ApiService(StorageService());
        }

        // Start scan
        _startNfcScan();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _scanState = NfcScanState.error;
          _scanMessage = 'Configuration error';
        });
        if (kDebugMode) {
          debugPrint('Error during initialization: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Make sure to stop NFC scanning if the page is closed
    if (_scanState == NfcScanState.scanning) {
      FlutterNfcKit.finish();
    }
    super.dispose();
  }

  /// Start the NFC scanning process
  Future<void> _startNfcScan() async {
    try {
      // Check if NFC is available on the device
      if (kDebugMode) {
        debugPrint('Checking NFC availability...');
      }
      final availability = await FlutterNfcKit.nfcAvailability;
      if (kDebugMode) {
        debugPrint('NFC availability: $availability');
      }

      if (availability != NFCAvailability.available) {
        // Show a detailed error message
        String errorMsg = AppLocalizations.of(context)!.nfcNotAvailable;

        // Add details about the error type
        if (availability == NFCAvailability.disabled) {
          errorMsg += ' (NFC disabled on the device)';
        } else if (availability == NFCAvailability.not_supported) {
          errorMsg += ' (NFC not supported by this device)';
        }

        _showErrorMessage(errorMsg);
        return;
      }

      // Start NFC polling
      setState(() {
        _scanState = NfcScanState.scanning;
      });

      if (kDebugMode) {
        debugPrint('Starting NFC scan...');
      }
      // Start polling with timeout of 60 seconds
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 60),
        iosMultipleTagMessage:
            AppLocalizations.of(context)!.nfcMultipleTagsDetected,
        iosAlertMessage: AppLocalizations.of(context)!.nfcScanningMessage,
      );

      if (tag.ndefAvailable ?? false) {
        // Read NDEF data if available
        final ndefRecords = await FlutterNfcKit.readNDEFRecords();
        final ndefData = _processNdefRecords(ndefRecords);

        if (ndefData != null && ndefData.isNotEmpty) {
          // Use the NDEF content as the main token
          await _processTagData(ndefData);
        } else {
          // Error if no NDEF content is present
          _showErrorMessage(AppLocalizations.of(context)!.nfcScanError);
        }
      } else {
        // Error if NDEF is not available
        _showErrorMessage(AppLocalizations.of(context)!.nfcScanError);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        try {
          // Always end the NFC session, regardless of the state
          await FlutterNfcKit.finish();

          // Update the state only if we were still scanning
          if (_scanState == NfcScanState.scanning) {
            setState(() {
              _scanState = NfcScanState.notSupported;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error closing NFC session: $e');
          }
          // Do not propagate this error
        }
      }
    }
  }

  /// Process NDEF records from the NFC tag if available
  String? _processNdefRecords(List<dynamic> records) {
    if (records.isEmpty) return null;

    // Look for a text record
    for (var record in records) {
      // Check if it's a TextRecord (specific format of flutter_nfc_kit)
      if (record.runtimeType.toString() == 'TextRecord') {
        // TextRecord has a text property directly accessible
        try {
          // Dynamically access the 'text' property
          final text = record.text;
          if (text != null && text.isNotEmpty) {
            return text;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error extracting text: $e');
          }
        }
      } else if (record.runtimeType.toString() == 'NDEFRecord') {
        // Format standard NDEFRecord
        try {
          if (record.typeNameFormat.toString() ==
                  'NFCTypeNameFormat.nfcWellKnown' &&
              record.type == 'T') {
            // Extract the text content
            final payload = record.payload;
            final languageLength = payload[0] & 0x3f;
            final text = utf8.decode(payload.sublist(1 + languageLength));
            return text;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error processing NDEFRecord: $e');
          }
        }
      }
    }

    // If no recognized format is found, try extracting directly
    try {
      // Try extracting the first record as plain text
      if (records.isNotEmpty && records[0].toString().isNotEmpty) {
        return records[0].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error extracting plain text: $e');
      }
    }

    return null;
  }

  /// Send the tag data to the API and handle the response
  Future<void> _processTagData(String token) async {
    String? artworkId;
    try {
      final deviceId = await _getDeviceId();

      // Prepare the data to send
      final data = {
        'token': token,
        'device_id': deviceId,
      };

      // Check that _apiService is properly initialized
      if (_apiService == null) {
        throw Exception('ApiService is not initialized');
      }

      // Send data to API
      final response = await _apiService!.post(
        '/api/nfc/scan',
        data: data,
      );

      if (!mounted) return;

      final responseData = response.data;
      if (response.statusCode == 200) {
        if (responseData['status'] == 'Success') {
          // Response status is Success
          // Ensure that the values are converted to String
          final points = responseData['pointsEarned'] != null
              ? responseData['pointsEarned'].toString()
              : '0';
          // Retrieve the artwork ID if present in the response
          artworkId = responseData['artworkId'] != null
              ? responseData['artworkId'].toString()
              : '';

          // Pass the complete artwork data to the display method
          _showSuccessMessage(AppLocalizations.of(context)!.nfcScanSuccessful,
              points: points, artworkId: artworkId, artworkData: responseData);

          // Get the artwork from the provider using the returned artwork ID
          final artworkProvider =
              Provider.of<ArtworkProvider>(context, listen: false);

          // Check if the artwork has been correctly collected
          final artworkIdValue = responseData['artworkId'] != null
              ? responseData['artworkId'].toString()
              : '';

          await artworkProvider.isArtworkInCollection(artworkIdValue);

          if (!mounted) return;
        } else if (responseData['status'] == 'AlreadyCollected') {
          _showErrorMessage(
              AppLocalizations.of(context)!.nfcArtworkAlreadyCollected,
              isAlreadyCollected: true,
              artworkData:
                  responseData // Pass the artwork data even if already collected
              );
        } else {
          _showErrorMessage(AppLocalizations.of(context)!.nfcUnknownStatus);
        }
      } else {
        _showErrorMessage(responseData['error'] ??
            AppLocalizations.of(context)!.nfcScanError);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e.toString());
    }
  }

  /// Show an error message and update the UI
  void _showErrorMessage(String message,
      {bool isAlreadyCollected = false, Map<String, dynamic>? artworkData}) {
    setState(() {
      _scanState = isAlreadyCollected
          ? NfcScanState.alreadyCollected
          : NfcScanState.error;
      _scanMessage = message;
      _artworkData = artworkData;

      // If it's already collected, we can still retrieve the artwork information
      if (isAlreadyCollected &&
          artworkData != null &&
          artworkData['artwork'] != null) {
        _artworkId = artworkData['artworkId']?.toString();
        _artworkTitle = artworkData['artwork']['title'] ?? '';
        _artworkArtist = artworkData['artwork']['artist'] ?? '';
      }
    });
  }

  /// Show a success message and update the UI
  void _showSuccessMessage(String message,
      {String? points, String? artworkId, Map<String, dynamic>? artworkData}) {
    setState(() {
      _scanState = NfcScanState.success;
      _scanMessage = message;
      if (points != null) {
        _pointsEarned = points;
      }
      // Store the artwork ID and information for navigation to the detail page
      _artworkId = artworkId;
      _artworkData = artworkData;

      // Extract the title and artist if available
      if (artworkData != null && artworkData['artwork'] != null) {
        _artworkTitle = artworkData['artwork']['title'] ?? '';
        _artworkArtist = artworkData['artwork']['artist'] ?? '';
      }
    });
  }

  /// Get the device identifier
  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId =
        'unknown_device_${DateTime.now().millisecondsSinceEpoch}'; // Fallback default

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Settings.Secure.ANDROID_ID
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId =
            iosInfo.identifierForVendor ?? deviceId; // Use fallback if null
      }
    } catch (e) {
      debugPrint('Error retrieving device ID: $e');
      // Keep the fallback default ID
    }
    return deviceId;
  }

  /// Try scanning again after an error
  void _retryScan() {
    setState(() {
      _scanMessage = '';
    });
    _startNfcScan();
  }

  // Refresh all data and close the NFC page
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

        await Future.wait([
          artworkProvider.refreshAllData(userId),
          userCollectionProvider.refreshAllData(),
          leaderboardProvider.refreshLeaderboard(),
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

  // Navigate to the detail page and refresh data on return
  Future<void> _viewArtworkAndRefreshOnReturn() async {
    if (_artworkData == null || _artworkData!['artwork'] == null) {
      debugPrint("Artwork data not available for navigation.");
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.errorLoadingArtworks)));
      }
      return;
    }

    final artwork = ArtworkModel.fromJson(_artworkData!['artwork']);
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
    // --- UI Construction ---

    // Content for success and already collected states (unified UI)
    if (_scanState == NfcScanState.success ||
        _scanState == NfcScanState.alreadyCollected) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message ('Scan successful' or 'Already collected')
          Text(
            _scanMessage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.purpleIndicator,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Artwork title and artist
          if (_artworkTitle.isNotEmpty) ...[
            Text(
              _artworkTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_artworkArtist.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_artworkArtist,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
          ],

          // Points earned (only if success)
          if (_scanState == NfcScanState.success &&
              _pointsEarned.isNotEmpty) ...[
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
                    '$_pointsEarned ${localizations.points}',
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
          if (_artworkId != null && _artworkId!.isNotEmpty) ...[
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
            _scanMessage,
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

    return WillPopScope(
      onWillPop: () async {
        if (_scanState == NfcScanState.success ||
            _scanState == NfcScanState.alreadyCollected) {
          await _refreshAndExit(); // Handle the pop and refresh
          return false; // Indicate that the pop has been handled
        } else if (_scanState == NfcScanState.scanning) {
          await FlutterNfcKit.finish();
          return true; // Allow the pop after stopping the NFC scan
        }
        return true; // Allow the pop for other states (error, etc.)
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.standardGrey),
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
                if (_scanState == NfcScanState.scanning) ...[
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
                ] else if (_scanState == NfcScanState.success ||
                    _scanState == NfcScanState.error ||
                    _scanState == NfcScanState.alreadyCollected) ...[
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: _buildScanResultContent(context, localizations),
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
  }
}
