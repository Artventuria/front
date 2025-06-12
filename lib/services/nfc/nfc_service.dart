import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

import '../api/api_service.dart';
import '../../models/nfc/nfc_scan_result_model.dart';
import 'device_service.dart';

/// Custom exception for when the user cancels an NFC session
class NFCSessionCanceledException implements Exception {
  final String message = 'NFC session canceled by user';
  
  @override
  String toString() => message;
}

class NfcService {
  final ApiService _apiService;
  final DeviceService _deviceService = DeviceService();

  NfcService(this._apiService);

  /// Check if NFC is available on the device
  Future<NFCAvailability> checkNfcAvailability() async {
    try {
      if (kDebugMode) {
        debugPrint('Checking NFC availability...');
      }
      final availability = await FlutterNfcKit.nfcAvailability;
      if (kDebugMode) {
        debugPrint('NFC availability: $availability');
      }
      return availability;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking NFC availability: $e');
      }
      return NFCAvailability.not_supported;
    }
  }

  /// Start NFC polling and return the scanned data
  Future<String?> pollNfcTag({
    Duration timeout = const Duration(seconds: 60),
    String? iosMultipleTagMessage,
    String? iosAlertMessage,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('Starting NFC scan...');
      }

      // Start polling with timeout
      final tag = await FlutterNfcKit.poll(
        timeout: timeout,
        iosMultipleTagMessage: iosMultipleTagMessage ?? 'Multiple tags found',
        iosAlertMessage: iosAlertMessage ?? 'Scan your tag',
      );

      if (tag.ndefAvailable ?? false) {
        // Read NDEF data if available
        final ndefRecords = await FlutterNfcKit.readNDEFRecords();
        return _processNdefRecords(ndefRecords);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during NFC polling: $e');
      }
      
      // Check if this is a session cancellation error
      if (e.toString().contains('PlatformException(409, SessionCanceled') || 
          e.toString().contains('Session invalidated by user')) {
        throw NFCSessionCanceledException();
      }
      
      rethrow;
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
  Future<NfcScanResultModel> processTagData(
      String token, String successMessage) async {
    try {
      final deviceId = await _deviceService.getDeviceId();

      // Prepare the data to send
      final data = {
        'token': token,
        'device_id': deviceId,
      };

      // Send data to API
      final response = await _apiService.post(
        '/api/nfc/scan',
        data: data,
      );

      final responseData = response.data;
      if (response.statusCode == 200) {
        if (responseData['status'] == 'Success') {
          return NfcScanResultModel.fromApiResponse(
              responseData, successMessage);
        } else {
          return NfcScanResultModel.fromApiResponse(
              responseData, responseData['message'] ?? 'Unknown status');
        }
      } else {
        return NfcScanResultModel.error(responseData['error'] ?? 'Scan error');
      }
    } catch (e) {
      return NfcScanResultModel.error(e.toString());
    }
  }

  /// Finish the NFC session
  Future<void> finishNfcSession() async {
    try {
      await FlutterNfcKit.finish();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error closing NFC session: $e');
      }
      // Do not propagate this error
    }
  }
}
