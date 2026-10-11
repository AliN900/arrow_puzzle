import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class StoreDetector {
  static const _channel = MethodChannel('store_detector');
  static String? _cachedInstaller;
  static bool? _cachedIsHuaweiDevice;

  static Future<String> getInstallerPackage() async {
    if (_cachedInstaller != null) return _cachedInstaller!;
    try {
      final result = await _channel.invokeMethod<String>('getInstallerPackage');
      _cachedInstaller = result ?? 'unknown';
      return _cachedInstaller!;
    } catch (_) {
      _cachedInstaller = 'unknown';
      return _cachedInstaller!;
    }
  }

  static Future<bool> isHuaweiAppGallery() async {
    final installer = await getInstallerPackage();
    return installer == 'com.huawei.appmarket';
  }

  static Future<bool> isGooglePlay() async {
    final installer = await getInstallerPackage();
    return installer == 'com.android.vending';
  }

  /// Returns true if the device is manufactured by Huawei or HONOR.
  /// Cached — value never changes during app lifetime.
  static Future<bool> isHuaweiDevice() async {
    if (_cachedIsHuaweiDevice != null) return _cachedIsHuaweiDevice!;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final brand = info.brand.toLowerCase();
      final manufacturer = info.manufacturer.toLowerCase();
      _cachedIsHuaweiDevice = brand.contains('huawei') ||
          manufacturer.contains('huawei') ||
          brand.contains('honor') ||
          manufacturer.contains('honor');
      return _cachedIsHuaweiDevice!;
    } catch (_) {
      _cachedIsHuaweiDevice = false;
      return false;
    }
  }
}