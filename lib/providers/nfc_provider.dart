import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import '../models/nfc/nfc_scan_result_model.dart';
import '../services/nfc/nfc_service.dart';
import '../services/api/api_service.dart';
import '../services/storage/storage_service.dart';

class NfcProvider extends ChangeNotifier {
  NfcService? _nfcService;
  NfcScanResultModel? _scanResult;
  NfcScanStatus _scanState = NfcScanStatus.scanning;
  bool _isScanning = false;

  // Getters
  NfcScanResultModel? get scanResult => _scanResult;
  NfcScanStatus get scanState => _scanState;
  bool get isScanning => _isScanning;

  /// Initialize the NFC service
  void initializeService(StorageService? storageService) {
    // Utiliser le storageService fourni ou en créer un nouveau, puis initialiser le ApiService avec
    final storage = storageService ?? StorageService();
    final apiService = ApiService(storage);
    _nfcService = NfcService(apiService);
  }

  /// Start the complete NFC scanning process
  Future<void> startNfcScan({
    String? iosMultipleTagMessage,
    String? iosAlertMessage,
    String? nfcNotAvailableMessage,
    String? nfcScanErrorMessage,
    String? nfcScanSuccessfulMessage,
    String? nfcArtworkAlreadyCollectedMessage,
    String? nfcUnknownStatusMessage,
    String? nfcSessionCanceledMessage,
  }) async {
    if (_nfcService == null) {
      _updateScanState(
        NfcScanStatus.error,
        NfcScanResultModel.error('NFC Service not initialized'),
      );
      return;
    }

    _isScanning = true;
    _updateScanState(NfcScanStatus.scanning, null);

    try {
      // Check if NFC is available on the device
      final availability = await _nfcService!.checkNfcAvailability();

      if (availability != NFCAvailability.available) {
        // Show a detailed error message
        String errorMsg = nfcNotAvailableMessage ?? 'NFC not available';

        // Add details about the error type
        if (availability == NFCAvailability.disabled) {
          errorMsg += ' (NFC disabled on the device)';
        } else if (availability == NFCAvailability.not_supported) {
          errorMsg += ' (NFC not supported by this device)';
        }

        _updateScanState(
          NfcScanStatus.error,
          NfcScanResultModel.error(errorMsg),
        );
        return;
      }

      // Start NFC polling
      final ndefData = await _nfcService!.pollNfcTag(
        iosMultipleTagMessage: iosMultipleTagMessage,
        iosAlertMessage: iosAlertMessage,
      );

      if (ndefData != null && ndefData.isNotEmpty) {
        // Use the NDEF content as the main token
        final result = await _nfcService!.processTagData(
          ndefData,
          nfcScanSuccessfulMessage ?? 'Scan successful',
        );

        // Handle different result statuses
        if (result.status == NfcScanStatus.alreadyCollected) {
          _updateScanState(
            NfcScanStatus.alreadyCollected,
            NfcScanResultModel(
              artworkId: result.artworkId,
              artworkTitle: result.artworkTitle,
              artworkArtist: result.artworkArtist,
              artworkData: result.artworkData,
              message: nfcArtworkAlreadyCollectedMessage ?? result.message,
              status: NfcScanStatus.alreadyCollected,
            ),
          );
        } else if (result.status == NfcScanStatus.success) {
          _updateScanState(NfcScanStatus.success, result);
        } else {
          _updateScanState(
            NfcScanStatus.error,
            NfcScanResultModel.error(nfcUnknownStatusMessage ?? result.message),
          );
        }
      } else {
        // Error if no NDEF content is present
        _updateScanState(
          NfcScanStatus.error,
          NfcScanResultModel.error(nfcScanErrorMessage ?? 'NFC scan error'),
        );
      }
    } catch (e) {
      if (e is NFCSessionCanceledException) {
        // Handle session cancellation with a user-friendly message
        _updateScanState(
          NfcScanStatus.canceled,
          NfcScanResultModel.error(nfcSessionCanceledMessage ??
              'NFC scan canceled, please try again'),
        );
      } else {
        // Handle other errors
        _updateScanState(
          NfcScanStatus.error,
          NfcScanResultModel.error(e.toString()),
        );
      }
    } finally {
      _isScanning = false;
      await _nfcService?.finishNfcSession();

      // Update the state only if we were still scanning
      if (_scanState == NfcScanStatus.scanning) {
        _updateScanState(
          NfcScanStatus.notSupported,
          NfcScanResultModel.error('NFC scan timeout or not supported'),
        );
      }
    }
  }

  /// Retry the NFC scan
  Future<void> retryScan({
    String? iosMultipleTagMessage,
    String? iosAlertMessage,
    String? nfcNotAvailableMessage,
    String? nfcScanErrorMessage,
    String? nfcScanSuccessfulMessage,
    String? nfcArtworkAlreadyCollectedMessage,
    String? nfcUnknownStatusMessage,
  }) async {
    _scanResult = null;
    await startNfcScan(
      iosMultipleTagMessage: iosMultipleTagMessage,
      iosAlertMessage: iosAlertMessage,
      nfcNotAvailableMessage: nfcNotAvailableMessage,
      nfcScanErrorMessage: nfcScanErrorMessage,
      nfcScanSuccessfulMessage: nfcScanSuccessfulMessage,
      nfcArtworkAlreadyCollectedMessage: nfcArtworkAlreadyCollectedMessage,
      nfcUnknownStatusMessage: nfcUnknownStatusMessage,
    );
  }

  /// Stop NFC scanning
  Future<void> stopNfcScan() async {
    _isScanning = false;
    await _nfcService?.finishNfcSession();
  }

  /// Update scan state and notify listeners
  void _updateScanState(NfcScanStatus state, NfcScanResultModel? result) {
    _scanState = state;
    _scanResult = result;
    notifyListeners();
  }

  /// Reset the provider state
  void reset() {
    _scanResult = null;
    _scanState = NfcScanStatus.scanning;
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopNfcScan();
    super.dispose();
  }
}
