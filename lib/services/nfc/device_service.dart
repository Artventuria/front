import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  /// Get the device identifier
  Future<String> getDeviceId() async {
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
}
