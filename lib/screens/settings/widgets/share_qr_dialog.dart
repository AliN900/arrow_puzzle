// =====================================================
// SHARE APP — QR CODE BOTTOM SHEET
// =====================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/status_flash.dart';

// ── Store link configuration ──────────────────────────
// Pass at build time:
//   flutter build apk --flavor=google --dart-define=STORE=google
//   flutter build apk --flavor=huawei --dart-define=STORE=huawei
const String _kStore =
String.fromEnvironment('STORE', defaultValue: 'google');

const String _kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=ahb.dev.arrow_puzzle';

// ⚠️ Replace C119286929 with the real consumer-facing AppGallery ID
// once the app is released.
const String _kHuaweiStoreUrl =
    'https://appgallery.huawei.com/app/C119286929';

String _currentStoreLink() =>
    _kStore == 'huawei' ? _kHuaweiStoreUrl : _kPlayStoreUrl;

String _currentStoreName() =>
    _kStore == 'huawei' ? 'Huawei AppGallery' : 'Google Play';

IconData _currentStoreIcon() =>
    _kStore == 'huawei' ? Icons.android : Icons.shop;

void showShareQR(BuildContext context) {
  final strings = AppStrings.of(context);
  final accent = AppColors.accent(context);
  final surface = AppColors.surface(context);
  final textPrimary = AppColors.textPrimary(context);
  final textSecondary = AppColors.textSecondary(context);

  final appLink = _currentStoreLink();
  final storeName = _currentStoreName();
  final storeIcon = _currentStoreIcon();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                strings.settingsShareFriends,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                strings.shareMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Store badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(storeIcon, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      storeName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // QR Code — always white container so the code stays
              // scannable regardless of the app's light/dark theme.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: appLink,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Copy Link button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: appLink));
                    Navigator.pop(sheetContext);
                    StatusFlash.success(context, strings.linkCopied);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(strings.copyLink),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}