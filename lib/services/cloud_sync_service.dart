import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_service.dart';

/// Read/write the single `player_saves` row for the current user.
class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  // ── Fetch row ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchSave(String userId) async {
    try {
      final row = await AppwriteService.tablesDb.getRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.playerSavesTableId,
        rowId: userId,
      );
      return row.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      debugPrint('CloudSync fetch failed: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('CloudSync fetch error: $e');
      return null;
    }
  }

  /// Legacy flat push — kept for backwards compat, not called by main().
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

  // ── Blob encode / decode ─────────────────────────────────────────

  String _encodeBlob(Map<String, dynamic> blob) {
    final raw = utf8.encode(jsonEncode(blob));
    final gzipped = GZipEncoder().encode(raw);
    return base64Encode(gzipped);
  }

  Map<String, dynamic>? _decodeBlob(String encoded) {
    try {
      final gzipped = base64Decode(encoded);
      final raw = GZipDecoder().decodeBytes(gzipped);
      return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Blob decode failed: $e');
      return null;
    }
  }

  // ── Full blob push / fetch ───────────────────────────────────────

  Future<void> pushFullSave({
    required String userId,
    required Map<String, dynamic> blob,
    required int currentLevel,
    required int coins,
  }) async {
    final encoded = _encodeBlob(blob);
    debugPrint('☁️ pushFullSave blob=${encoded.length} chars');

    final data = <String, dynamic>{
      'userId': userId,
      'currentLevel': currentLevel,
      'coins': coins,
      'saveBlob': encoded,
      'lastPlayed': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await AppwriteService.tablesDb.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: AppwriteService.playerSavesTableId,
        rowId: userId,
        data: data,
      );
      debugPrint('☁️ pushFullSave OK');
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        try {
          await AppwriteService.tablesDb.createRow(
            databaseId: AppwriteService.databaseId,
            tableId: AppwriteService.playerSavesTableId,
            rowId: userId,
            data: data,
          );
          debugPrint('☁️ pushFullSave created row');
        } catch (createErr) {
          debugPrint('🔴 pushFullSave create failed: $createErr');
        }
      } else {
        debugPrint('🔴 pushFullSave update failed (${e.code}): ${e.message}');
      }
    } catch (e) {
      debugPrint('🔴 pushFullSave error: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchFullSave(String userId) async {
    final row = await fetchSave(userId);
    if (row == null) {
      debugPrint('☁️ fetchFullSave: no row');
      return null;
    }
    final raw = row['saveBlob'] as String?;
    if (raw == null || raw.isEmpty) {
      debugPrint('☁️ fetchFullSave: no blob yet');
      return null;
    }
    final decoded = _decodeBlob(raw);
    debugPrint(
        '☁️ fetchFullSave: blob=${raw.length} chars, decoded=${decoded != null}');
    return decoded;
  }

  /// Fire-and-forget call to `update_player_data` Appwrite function.
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