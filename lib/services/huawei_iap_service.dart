import 'package:flutter/foundation.dart';
import 'package:huawei_iap/huawei_iap.dart';

/// Product types in Huawei IAP.
class HuaweiProductType {
  static const int consumable = IapClient.IN_APP_CONSUMABLE;      // 0
  static const int nonConsumable = IapClient.IN_APP_NONCONSUMABLE; // 1
}

/// Result of a successful purchase.
class HuaweiPurchaseResult {
  final bool success;
  final String? productId;
  final String? purchaseToken;
  final String? errorMessage;

  HuaweiPurchaseResult({
    required this.success,
    this.productId,
    this.purchaseToken,
    this.errorMessage,
  });
}

class HuaweiIapService {
  static bool _initialized = false;

  /// Call once at app start (after StoreService.detect() confirms Huawei).
  static Future<bool> init() async {
    try {
      final result = await IapClient.isEnvReady();
      _initialized = result.returnCode == '0';
      debugPrint('Huawei IAP env ready: $_initialized');
      return _initialized;
    } catch (e) {
      debugPrint('Huawei IAP init failed: $e');
      return false;
    }
  }

  /// Query products from AGC. Call to display prices in the shop.
  static Future<List<ProductInfo>> queryProducts(
      List<String> productIds, {
        bool consumable = true,
      }) async {
    if (!_initialized) await init();

    try {
      final req = ProductInfoReq(
        priceType: consumable
            ? HuaweiProductType.consumable
            : HuaweiProductType.nonConsumable,
        skuIds: productIds,
      );

      final res = await IapClient.obtainProductInfo(req);
      if (res.returnCode == '0') {
        return res.productInfoList ?? [];
      }
      debugPrint('Query failed: ${res.errMsg}');
      return [];
    } catch (e) {
      debugPrint('Query error: $e');
      return [];
    }
  }

  /// Launch the purchase flow for a single product.
  static Future<HuaweiPurchaseResult> purchase(
      String productId, {
        bool consumable = true,
      }) async {
    if (!_initialized) await init();

    try {
      final req = PurchaseIntentReq(
        productId: productId,
        priceType: consumable
            ? HuaweiProductType.consumable
            : HuaweiProductType.nonConsumable,
      );

      final res = await IapClient.createPurchaseIntent(req);

      if (res.returnCode == '0' && res.inAppPurchaseData != null) {
        // inAppPurchaseData is already an InAppPurchaseData object.
        final data = res.inAppPurchaseData!;
        return HuaweiPurchaseResult(
          success: true,
          productId: data.productId,
          purchaseToken: data.purchaseToken,
        );
      } else {
        return HuaweiPurchaseResult(
          success: false,
          errorMessage: res.errMsg ?? 'Purchase cancelled',
        );
      }
    } catch (e) {
      return HuaweiPurchaseResult(success: false, errorMessage: '$e');
    }
  }

  /// Consume a purchased item so the user can buy it again.
  /// Only for consumables (hints, coins, items).
  static Future<bool> consume(String purchaseToken) async {
    try {
      final req = ConsumeOwnedPurchaseReq(purchaseToken: purchaseToken);
      final res = await IapClient.consumeOwnedPurchase(req);
      return res.returnCode == '0';
    } catch (e) {
      debugPrint('Consume error: $e');
      return false;
    }
  }

  /// Query purchases the user owns (for non-consumables like remove-ads).
  static Future<List<InAppPurchaseData>> ownedPurchases({
    bool consumable = false,
  }) async {
    try {
      final req = OwnedPurchasesReq(
        priceType: consumable
            ? HuaweiProductType.consumable
            : HuaweiProductType.nonConsumable,
      );
      final res = await IapClient.obtainOwnedPurchases(req);
      if (res.returnCode == '0' && res.inAppPurchaseDataList != null) {
        // inAppPurchaseDataList is already a List<InAppPurchaseData>.
        return res.inAppPurchaseDataList!;
      }
      return [];
    } catch (e) {
      debugPrint('Owned query error: $e');
      return [];
    }
  }
}