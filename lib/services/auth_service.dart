import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'appwrite_service.dart';

enum AuthMethod { guest, email, google, apple }

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _boxName = 'authPrefs';
  static const String _kMethod = 'lastAuthMethod';
  static const String _kUserId = 'cachedUserId';
  static const String _kEmail = 'cachedEmail';
  static const String _kName = 'cachedName';
  static const String _kAvatarUrl = 'cachedAvatarUrl';

  Box? _boxCache;

  AuthMethod _method = AuthMethod.guest;
  String? _userId;
  String? _email;
  String? _name;
  String? _avatarUrl;
  bool _bootstrapped = false;

  AuthMethod get method => _method;
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  String? get avatarUrl => _avatarUrl;
  bool get isGuest => _method == AuthMethod.guest;
  bool get isSignedIn => _bootstrapped && !isGuest;

  String get displayName {
    if (_name != null && _name!.trim().isNotEmpty) return _name!.trim();
    if (_email != null) return _email!.split('@').first;
    return 'Guest';
  }

  String get avatarInitial {
    final n = displayName.trim();
    return n.isEmpty ? 'P' : n[0].toUpperCase();
  }

  String get providerLabel {
    switch (_method) {
      case AuthMethod.email:
        return 'via Email';
      case AuthMethod.google:
        return 'via Google';
      case AuthMethod.apple:
        return 'via Apple';
      case AuthMethod.guest:
        return 'Guest account';
    }
  }

  // ── Box helper ──────────────────────────────────────────────────────

  Future<Box> _getBox() async {
    if (_boxCache != null && _boxCache!.isOpen) return _boxCache!;
    _boxCache = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    return _boxCache!;
  }

// Add this method inside your AuthService class:
  Future<void> syncProfileToAppwrite() async {
    if (_userId == null || isGuest) return; // Don't sync guests

    try {
      // Try to update the row first
      await AppwriteService.tablesDb.updateRow(
        databaseId: AppwriteService.databaseId,
        tableId: '6ae356e900356fdb7ddb',
        rowId: _userId!,  // Use the Auth ID as the row ID
        data: {
          'userId': _userId,
          'userName': displayName,
          // 'level': AppwriteService... // See Step 2 below
        },
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        // Row doesn't exist yet, create it
        try {
          await AppwriteService.tablesDb.createRow(
            databaseId: AppwriteService.databaseId,
            tableId: '6ae356e900356fdb7ddb',
            rowId: _userId!,
            data: {
              'userId': _userId,
              'userName': displayName,
              'level': 1, // Default starting level
            },
          );
        } catch (createErr) {
          debugPrint('🔴 [Auth] Failed to create users row: $createErr');
        }
      }
    } catch (e) {
      debugPrint('🔴 [Auth] Failed to sync profile: $e');
    }
  }

  /// Persist the current user's data to Hive. Called after every successful
  /// sign-in so the UI can restore state without a network round-trip.
  Future<void> _persistUserToBox(Box box) async {
    await box.put(_kMethod, _method.name);
    if (_userId != null) await box.put(_kUserId, _userId);
    if (_email != null) await box.put(_kEmail, _email);
    if (_name != null) await box.put(_kName, _name);
    if (_avatarUrl != null) await box.put(_kAvatarUrl, _avatarUrl);
  }

  Future<void> _clearUserFromBox(Box box) async {
    await box.delete(_kUserId);
    await box.delete(_kEmail);
    await box.delete(_kName);
    await box.delete(_kAvatarUrl);
  }

  // ── Boot ────────────────────────────────────────────────────────────

  Future<void> bootstrap() async {
    await AppwriteService.init();
    final box = await _getBox();

    // 1. Restore cached user state from Hive FIRST — instant, offline-safe.
    final cachedUserId = box.get(_kUserId) as String?;
    final cachedEmail = box.get(_kEmail) as String?;
    final cachedName = box.get(_kName) as String?;
    final cachedAvatar = box.get(_kAvatarUrl) as String?;
    final savedMethod = box.get(_kMethod) as String?;

    if (cachedUserId != null && cachedEmail != null && savedMethod != null) {
      _userId = cachedUserId;
      _email = cachedEmail;
      _name = cachedName;
      _avatarUrl = cachedAvatar;
      _method = AuthMethod.values.firstWhere(
            (m) => m.name == savedMethod,
        orElse: () => AuthMethod.email,
      );
      _bootstrapped = true;
      notifyListeners();
      debugPrint('🟢 [Auth] Restored cached user: $cachedEmail');
    }

    // 2. Verify with Appwrite in the background.
    try {
      final user = await AppwriteService.account.get();

      // ⚠️ Only apply the Appwrite user if it does NOT downgrade our state.
      // If we have a cached signed-in user and Appwrite returns an anonymous
      // session (cookie didn't persist), keep the cached state.
      final appwriteIsAnon = user.email.isEmpty;

      if (appwriteIsAnon) {
        // ✅ FIX: If Appwrite says we are anonymous, we ARE a guest.
        // Clear the cached email so we don't try to sync.
        _userId = user.$id;
        _email = null;
        _method = AuthMethod.guest;
        _name = user.name.isEmpty ? cachedName : user.name; // Keep local name

        await box.delete(_kEmail); // Clear cached email
        await box.put(_kMethod, AuthMethod.guest.name);
        debugPrint('🟡 [Auth] Appwrite session is guest. Enforcing guest mode (no sync).');
      } else {
        _applyUser(user);
        if (_email != null && _method == AuthMethod.guest) {
          _method = savedMethod != null
              ? AuthMethod.values.firstWhere(
                (m) => m.name == savedMethod,
            orElse: () => AuthMethod.email,
          )
              : AuthMethod.email;
        }
        await _persistUserToBox(box);
        await syncProfileToAppwrite(); // 👈 ADD THIS LINE
        debugPrint('🟢 [Auth] Verified with Appwrite: ${user.email}');
      }
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // ✅ FIX: If the session is dead, we are a GUEST. Period.
        // We must clear the cached email to stop the sync.
        final box = await _getBox();
        await box.delete(_kEmail);
        await box.delete(_kUserId);

        debugPrint('🟡 [Auth] Session lost. Forcing Guest mode.');

        try {
          final session = await AppwriteService.account.createAnonymousSession();
          _userId = session.userId;
          _method = AuthMethod.guest;
          _email = null;
          _avatarUrl = null;
          _name = cachedName ?? 'Guest';

          await box.put(_kMethod, AuthMethod.guest.name);
          await box.put(_kName, _name);
          await box.put(_kUserId, _userId);
          debugPrint('🟢 [Auth] Created new anonymous session after 401');
        } catch (inner) {
          debugPrint('🔴 [Auth] Anonymous session failed: $inner');
        }
      } else {
        debugPrint('🟡 [Auth] Bootstrap check failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('🟡 [Auth] Bootstrap error: $e');
    }

    _bootstrapped = true;
    notifyListeners();
  }

  void _applyUser(User user) {
    _userId = user.$id;
    _email = user.email.isEmpty ? null : user.email;
    _name = user.name.isEmpty ? null : user.name;
    _avatarUrl = user.prefs.data['picture'] as String?;

    if (_email == null) {
      _method = AuthMethod.guest;
    } else if (_method == AuthMethod.guest) {
      _method = AuthMethod.email;
    }
  }

  Future<void> _dropCurrentSession() async {
    try {
      await AppwriteService.account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint('No session to drop: $e');
    }
  }

  Future<void> _ensureAnonymousSession() async {
    try {
      await AppwriteService.account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // ── 1. DECLARE BOX FIRST & CLEAR OLD DATA ──
        final box = await _getBox();
        await _clearUserFromBox(box); // Clear the old session data first

        final session = await AppwriteService.account.createAnonymousSession();
        _userId = session.userId;
        _method = AuthMethod.guest;
        _email = null;
        _avatarUrl = null;

        // ── 2. AUTO-ASSIGN A NAME ──
        final defaultName = 'Guest';
        try {
          await AppwriteService.account.updateName(name: defaultName);
          _name = defaultName;
        } catch (_) {
          _name = defaultName;
        }

        // ── 3. SAVE TO LOCAL BOX ──
        await box.put(_kMethod, AuthMethod.guest.name);
        await box.put(_kName, _name);
        await box.put(_kUserId, _userId);

        notifyListeners();
      }
    } catch (_) {}
  }


  // ── Sign-in / sign-up ───────────────────────────────────────────────

  Future<void> upgradeToEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    debugPrint('🟢 [Email] 1. starting upgrade to $email');
    try {
      await AppwriteService.account.updateEmail(
        email: email,
        password: password,
      );
      debugPrint('🟢 [Email] 2. updateEmail succeeded');

      // ✅ FIX: Use the typed name, OR fallback to the local guest name
      final nameToSet = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : _name;

      if (nameToSet != null && nameToSet.trim().isNotEmpty) {
        await AppwriteService.account.updateName(name: nameToSet.trim());
        debugPrint('🟢 [Email] 3. updateName succeeded: $nameToSet');
      }

      final user = await AppwriteService.account.get();
      debugPrint('🟢 [Email] 4. userId=${user.$id} email=${user.email}');
      _applyUser(user);
      _method = AuthMethod.email;
      _bootstrapped = true;
      final box = await _getBox();
      await _persistUserToBox(box);
      await syncProfileToAppwrite();
      notifyListeners();
      debugPrint('🟢 [Email] 5. done, isSignedIn=$isSignedIn');
    } catch (e, st) {
      debugPrint('🔴 [Email] failed: $e');
      debugPrint('🔴 [Email] stack: $st');
      rethrow;
    }
  }

  Future<void> updateDisplayName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    debugPrint('🟢 [Auth] Trying to update name to: $trimmed. Is Guest: $isGuest, Email: $_email');

    if (_email != null) {
      try {
        // 1. Push the new name to Appwrite
        await AppwriteService.account.updateName(name: trimmed);

        // 2. Fetch the user again to VERIFY it actually saved
        final updatedUser = await AppwriteService.account.get();

        if (updatedUser.name == trimmed) {
          debugPrint('✅ [Auth] CONFIRMED: Appwrite saved the name as ${updatedUser.name}');
        } else {
          debugPrint('⚠️ [Auth] Appwrite did NOT save the name. It is still: "${updatedUser.name}"');
        }

      } on AppwriteException catch (e) {
        debugPrint('🔴 Appwrite name update failed: ${e.code} - ${e.message}');
        if (e.code == 401) {
          throw Exception('Session expired. Please sign out and sign in again.');
        }
        rethrow;
      }
    } else {
      debugPrint('🟡 [Auth] Guest changed name locally. Will sync when they sign up.');
    }

    _name = trimmed;
    final box = await _getBox();
    await box.put(_kName, trimmed);
    await _persistUserToBox(box);
    await syncProfileToAppwrite();
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await AppwriteService.account.deleteSession(sessionId: 'current');
    } catch (_) {}

    await AppwriteService.account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    final user = await AppwriteService.account.get();
    _applyUser(user);

    // ✅ FIX: If Appwrite doesn't have a name, push the local name to Appwrite!
    if (user.name.isEmpty) {
      final box = await _getBox();
      final localName = box.get(_kName) as String?;

      if (localName != null && localName.isNotEmpty && localName != 'Guest') {
        try {
          await AppwriteService.account.updateName(name: localName);
          _name = localName; // Restore the local name in memory
          debugPrint('🟢 [Auth] Pushed local name to Appwrite on Sign In: $localName');
        } catch (e) {
          debugPrint('🔴 [Auth] Failed to push name on Sign In: $e');
        }
      }
    }

    _method = AuthMethod.email;
    _bootstrapped = true;
    final box = await _getBox();
    await _persistUserToBox(box);
    await syncProfileToAppwrite();
    notifyListeners();
  }

  static bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId:
      '1045138021655-maguheo1029voaa6etdqdtut4unikuh2l.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  Future<void> signInWithGoogle() async {
    debugPrint('🔵 [Google] 1. starting native sign-in');
    try {
      await _ensureGoogleInitialized();
      debugPrint('🔵 [Google] initialized');

      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      // NOTE: authentication is a synchronous getter in google_sign_in 7.x.
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('🔴 [Google] no ID token');
        throw Exception('No ID token received from Google');
      }

      debugPrint('🔵 [Google] 2. got ID token, exchanging with Appwrite');

      await AppwriteService.account.createIdTokenSession(
        provider: IdTokenProvider.google,
        idToken: idToken,
      );

      debugPrint('🔵 [Google] 3. session created');

      final user = await AppwriteService.account.get();
      debugPrint('🔵 [Google] 4. userId=${user.$id} email=${user.email}');

      _applyUser(user);
      _method = AuthMethod.google;
      _bootstrapped = true;
      final box = await _getBox();
      await _persistUserToBox(box);
      await syncProfileToAppwrite();
      notifyListeners();
      debugPrint('🔵 [Google] 5. done, isSignedIn=$isSignedIn');
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('🔵 [Google] user cancelled');
        return;
      }
      debugPrint(
          '🔴 [Google] GoogleSignInException: ${e.code} ${e.description}');
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('🔴 [Google] PlatformException: ${e.code} ${e.message}');
      rethrow;
    } on AppwriteException catch (e) {
      debugPrint('🔴 [Google] AppwriteException: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('🔴 [Google] unexpected: $e');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    await _dropCurrentSession();
    try {
      await AppwriteService.account.createOAuth2Session(
        provider: OAuthProvider.apple,
        success: '$_oauthScheme://',
        failure: '$_oauthScheme://',
      );
      _applyUser(await AppwriteService.account.get());
      _method = AuthMethod.apple;
      _bootstrapped = true;
      final box = await _getBox();
      await _persistUserToBox(box);
      await syncProfileToAppwrite();
      notifyListeners();
    } on AppwriteException catch (e) {
      debugPrint('Apple OAuth failed: code=${e.code} message=${e.message}');
      await _ensureAnonymousSession();
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('Apple OAuth platform error: code=${e.code} msg=${e.message}');
      await _ensureAnonymousSession();
      rethrow;
    } catch (e) {
      debugPrint('Apple OAuth unexpected: $e');
      await _ensureAnonymousSession();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await AppwriteService.account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint('Sign-out failed (ignored): $e');
    }

    final box = await _getBox();
    await _clearUserFromBox(box);

    try {
      final session = await AppwriteService.account.createAnonymousSession();
      _userId = session.userId;
      _method = AuthMethod.guest;
      _email = null;
      _avatarUrl = null;

      // Auto-assign name
      final defaultName = 'Guest';
      try {
        await AppwriteService.account.updateName(name: defaultName);
        _name = defaultName;
      } catch (_) {
        _name = defaultName;
      }

      await box.put(_kMethod, AuthMethod.guest.name);
      await box.put(_kName, _name);
    } catch (e) {
      debugPrint('Guest session after sign-out failed: $e');
      _method = AuthMethod.guest;
      _userId = null;
      _email = null;
      _name = null;
      _avatarUrl = null;
    }

    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try {
      final functions = AppwriteService.functions;
      final execution = await functions.createExecution(
        functionId: 'delete_user_account',
        xasync: false,
      );

      if (execution.responseStatusCode != 200) {
        throw Exception('Function failed: ${execution.responseBody}');
      }

      final response = jsonDecode(execution.responseBody);

      if (response['success'] != true) {
        throw Exception('Failed to delete account: ${response['error']}');
      }

      final box = await _getBox();
      await _clearUserFromBox(box);

      _userId = null;
      _email = null;
      _name = null;
      _avatarUrl = null;
      _method = AuthMethod.guest;

      final session = await AppwriteService.account.createAnonymousSession();
      _userId = session.userId;
      _method = AuthMethod.guest;
      _email = null;
      _avatarUrl = null;

      // Auto-assign name
      final defaultName = 'Guest';
      try {
        await AppwriteService.account.updateName(name: defaultName);
        _name = defaultName;
      } catch (_) {
        _name = defaultName;
      }

      await box.put(_kMethod, AuthMethod.guest.name);
      await box.put(_kName, _name);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete account: $e');
      rethrow;
    }
  }

  static const String _oauthScheme =
      'appwrite-callback-6ac33d18001a1531eed9';
}