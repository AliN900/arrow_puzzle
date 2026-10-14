import 'package:appwrite/appwrite.dart';

/// Thin wrapper around the Appwrite client. Keeps the project IDs in one
/// place and exposes a lazily-authenticated user id.
///
/// Uses lazy getters instead of `late final` statics so that hot restart
/// (or any partial init failure) can never leave the service in an
/// uninitialized state.
class AppwriteService {
  AppwriteService._();

  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '6ac33d18001a1531eed9';

  // Database ID (from the URL: /databases/tablesdb/<THIS>)
  static const String databaseId = '6ac33f510029701224d3';

  // Table IDs (from the URL: /tables/<THIS>)
  static const String playerSavesTableId = '6ac343f1002096fab535';
  static const String leaderboardTableId = 'leaderboard';

  static const String updatePlayerDataFunctionId = '6ac34013001f8181821d';

  // ── Nullable backing fields (NOT late final) ──
  static Client? _client;
  static Account? _account;
  static TablesDB? _tablesDb;
  static Functions? _functions;

  // ── Lazy getters — first access builds the object ──
  static Client get client => _client ??= _buildClient();
  static Account get account => _account ??= Account(client);
  static TablesDB get tablesDb => _tablesDb ??= TablesDB(client);
  static Functions get functions => _functions ??= Functions(client);

  static Client _buildClient() =>
      Client().setEndpoint(endpoint).setProject(projectId);

  /// True once the client has been materialized.
  static bool get isReady => _client != null;

  /// Kept for compatibility with the previous API surface. The lazy
  /// getters mean this is now effectively a no-op, but existing code
  /// that awaits `init()` still works.
  static Future<void> init() async {
    // Force initialization by touching the getters.
    client;
    account;
    tablesDb;
    functions;
  }

  /// Kept for backwards compat with the old boot code — new code should
  /// call `AuthService.instance.bootstrap()` instead.
  static Future<String> ensureUser() async {
    try {
      final user = await account.get();
      return user.$id;
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        final session = await account.createAnonymousSession();
        return session.userId;
      }
      rethrow;
    }
  }
}