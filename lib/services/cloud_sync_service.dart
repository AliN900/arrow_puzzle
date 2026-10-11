import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_service.dart';

/// Read/write the single `player_saves` row for the current user.
class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  /// Fetch the remote save for [userId], or null if it doesn't exist yet.
  Future<Map<String, dynamic>?> fetchSave(String userId) async {
    try {
      final row = await AppwriteService.tablesDb.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.playerSavesTableId,
        rowId: userId,
      );
      return row.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) return null; // first launch for this user
      debugPrint('CloudSync fetch failed: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('CloudSync fetch error: $e');
      return null;
    }
  }

  /// Create-or-update the save row. Safe to call frequently — silent on
  /// failure so a flaky network never blocks gameplay.
  Future<void> pushSave({
    required String userId,
    required int currentLevel,
    required int coins,
  }) async {
    final data = <String, dynamic>{
      'userId': userId,
      'currentLevel': currentLevel,
      'coins': coins,
      'lastPlayed': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await AppwriteService.tablesDb.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.playerSavesTableId,
        rowId: userId,
        data: data,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        // No row yet — create one with the deterministic rowId = userId.
        try {
          await AppwriteService.tablesDb.createRow(
            databaseId: AppwriteService.databaseId,
            tableId: AppwriteService.playerSavesTableId,
            rowId: userId,
            data: data,
          );
        } catch (createErr) {
          debugPrint('CloudSync create failed: $createErr');
        }
      } else {
        debugPrint('CloudSync update failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('CloudSync push error: $e');
    }
  }

  /// Fire-and-forget call to your `update_player_data` Appwrite function.
  /// Useful if you want server-side logic (e.g. validation, leaderboards)
  /// to run on every save.
  Future<void> invokeUpdateFunction() async {
    try {
      await AppwriteService.functions.createExecution(
        functionId: AppwriteService.updatePlayerDataFunctionId,
        body: '{}',
        xasync: true,
      );
    } catch (e) {
      debugPrint('CloudSync function call failed: $e');
    }
  }
}