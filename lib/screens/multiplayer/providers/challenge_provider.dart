import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Challenger {
  final String id;
  final String name;
  final int level;
  final String? challengeDocId;
  final bool isOnline;

  Challenger({
    required this.id,
    required this.name,
    required this.level,
    this.challengeDocId,
    this.isOnline = true,
  });
}

class ChallengeState {
  final bool isReady;
  final List<Challenger> availablePlayers;
  final Challenger? incomingCaller;
  final bool isChallenging;
  final String? challengingName;
  final Challenger? matchOpponent;
  final String? activeChallengeId;
  final bool isMatchAccepted;
  final bool p1Ready;
  final bool p2Ready;
  final String difficulty;
  final int matchSeed;
  final bool isLaunching;
  final int p1Cleared;
  final int p2Cleared;
  final String? winnerId;
  final bool isInMatch;

  ChallengeState({
    this.isReady = false,
    this.availablePlayers = const [],
    this.incomingCaller,
    this.isChallenging = false,
    this.challengingName,
    this.matchOpponent,
    this.activeChallengeId,
    this.isMatchAccepted = false,
    this.p1Ready = false,
    this.p2Ready = false,
    this.difficulty = 'hard',
    this.matchSeed = 0,
    this.isLaunching = false,
    this.p1Cleared = 0,
    this.p2Cleared = 0,
    this.winnerId,
    this.isInMatch = false,
  });

  ChallengeState copyWith({
    bool? isReady,
    List<Challenger>? availablePlayers,
    Challenger? incomingCaller,
    bool clearIncomingCaller = false,
    bool? isChallenging,
    String? challengingName,
    Challenger? matchOpponent,
    bool clearMatchOpponent = false,
    String? activeChallengeId,
    bool clearActiveChallengeId = false,
    bool? isMatchAccepted,
    bool? p1Ready,
    bool? p2Ready,
    String? difficulty,
    int? matchSeed,
    bool? isLaunching,
    int? p1Cleared,
    int? p2Cleared,
    String? winnerId,
    bool clearWinnerId = false,
    bool? isInMatch,
  }) {
    return ChallengeState(
      isReady: isReady ?? this.isReady,
      availablePlayers: availablePlayers ?? this.availablePlayers,
      incomingCaller: clearIncomingCaller ? null : (incomingCaller ?? this.incomingCaller),
      isChallenging: isChallenging ?? this.isChallenging,
      challengingName: challengingName ?? this.challengingName,
      matchOpponent: clearMatchOpponent ? null : (matchOpponent ?? this.matchOpponent),
      activeChallengeId: clearActiveChallengeId ? null : (activeChallengeId ?? this.activeChallengeId),
      isMatchAccepted: isMatchAccepted ?? this.isMatchAccepted,
      p1Ready: p1Ready ?? this.p1Ready,
      p2Ready: p2Ready ?? this.p2Ready,
      difficulty: difficulty ?? this.difficulty,
      matchSeed: matchSeed ?? this.matchSeed,
      isLaunching: isLaunching ?? this.isLaunching,
      p1Cleared: p1Cleared ?? this.p1Cleared,
      p2Cleared: p2Cleared ?? this.p2Cleared,
      winnerId: clearWinnerId ? null : (winnerId ?? this.winnerId),
      isInMatch: isInMatch ?? this.isInMatch,
    );
  }
}

class ChallengeNotifier extends Notifier<ChallengeState> {
  final String dbId = '6ac33f510029701224d3';
  final String lobbiesId = '6ae0dbf0002fc32e405c';
  final String challengesId = '6ae0dbf9000e37c2a794';

  TablesDB? tablesDB;
  Realtime? realtime;
  RealtimeSubscription? _challengeSub;
  RealtimeSubscription? _lobbySub;

  String? _myUserId;
  String? _myName;
  int? _myLevel;

  @override
  ChallengeState build() {
    ref.onDispose(() {
      _challengeSub?.close();
      _lobbySub?.close();
    });
    return ChallengeState();
  }

  void initAppwrite(TablesDB db, Realtime rt, String userId, String userName, int level) {
    if (tablesDB != null && _myUserId == userId) return;
    tablesDB = db;
    realtime = rt;
    _myUserId = userId;
    _myName = userName;
    _myLevel = level;

    _fetchLobbies();
    _listenToLobbies();
    _listenToChallenges();
  }

  void resetChallengeState() {
    state = state.copyWith(
      isChallenging: false,
      isMatchAccepted: false,
      isLaunching: false,
      clearMatchOpponent: true,
      clearActiveChallengeId: true,
      p1Ready: false,
      p2Ready: false,
      p1Cleared: 0,
      p2Cleared: 0,
      clearWinnerId: true,
    );
  }

  // 👈 TOGGLE LOBBY READY (Random Match)
  Future<void> toggleReady(bool value) async {
    state = state.copyWith(isReady: value);
    if (tablesDB == null || _myUserId == null) return;

    try {
      if (value) {
        await tablesDB!.createRow(
          databaseId: dbId, tableId: lobbiesId, rowId: ID.unique(),
          data: {'userId': _myUserId, 'userName': _myName, 'level': _myLevel, 'isReady': true},
        );
      } else {
        final docs = await tablesDB!.listRows(
          databaseId: dbId, tableId: lobbiesId, queries: [Query.equal('userId', _myUserId!)],
        );
        for (var doc in docs.rows) {
          await tablesDB!.deleteRow(databaseId: dbId, tableId: lobbiesId, rowId: doc.$id);
        }
      }
    } catch (e) {
      debugPrint('🔴 [Challenge] Toggle Lobby error: $e');
      state = state.copyWith(isReady: !value); // Revert on failure
    }
  }

  Future<void> _fetchLobbies() async {
    if (tablesDB == null || _myUserId == null) return;
    try {
      final docs = await tablesDB!.listRows(databaseId: dbId, tableId: lobbiesId);
      final players = docs.rows.map((doc) => Challenger(
        id: doc.data['userId'], name: doc.data['userName'] ?? 'Player', level: doc.data['level'],
      )).where((p) => p.id != _myUserId).toList();
      state = state.copyWith(availablePlayers: players);
    } catch (_) {}
  }

  void _listenToLobbies() {
    _lobbySub = realtime!.subscribe(['databases.$dbId.tables.$lobbiesId.rows']);
    _lobbySub!.stream.listen((_) => _fetchLobbies());
  }

  void setInMatch(bool value) {
    state = state.copyWith(isInMatch: value);
  }

  void _listenToChallenges() {
    _challengeSub = realtime!.subscribe(['databases.$dbId.tables.$challengesId.rows']);
    _challengeSub!.stream.listen((response) {
      final data = response.payload;

      if (response.events.contains('databases.*.tables.*.rows.*.create')) {
        if (data['challengedId'] == _myUserId && data['status'] == 'pending') {

          // 👈 NEW: AUTO-DECLINE if player is in a match
          if (state.isInMatch) {
            tablesDB!.deleteRow(
                databaseId: dbId,
                tableId: challengesId,
                rowId: data['\$id']
            ).catchError((_) {});
            return; // Stop processing, so the popup never shows
          }

          state = state.copyWith(
            incomingCaller: Challenger(
              id: data['challengerId'], name: data['challengerName'] ?? 'Unknown',
              level: data['challengerLevel'] ?? 1, challengeDocId: data['\$id'],
            ),
          );
        }
      }

      if (response.events.contains('databases.*.tables.*.rows.*.update')) {
        if (data['challengerId'] == _myUserId || data['challengedId'] == _myUserId) {
          state = state.copyWith(
            p1Ready: data['p1Ready'] ?? false,
            p2Ready: data['p2Ready'] ?? false,
            difficulty: data['difficulty'] ?? 'hard',
            matchSeed: data['matchSeed'] ?? 0,
            p1Cleared: data['p1Cleared'] ?? 0,
            p2Cleared: data['p2Cleared'] ?? 0,
            winnerId: data['winnerId']?.isNotEmpty == true ? data['winnerId'] : null,
          );

          if (data['status'] == 'accepted' && state.isChallenging) {
            state = state.copyWith(
              isChallenging: false,
              isMatchAccepted: true,
              activeChallengeId: data['\$id'],
            );
          }

          if (data['status'] == 'starting') {
            state = state.copyWith(isLaunching: true);
          }
        }
      }

      if (response.events.contains('databases.*.tables.*.rows.*.delete')) {
        if (data['challengedId'] == _myUserId || data['challengerId'] == _myUserId) {
          resetChallengeState();
          state = state.copyWith(clearIncomingCaller: true);
        }
      }
    });
  }

  Future<void> sendChallenge(Challenger target) async {
    if (tablesDB == null) return;
    resetChallengeState();
    try {
      final rowId = ID.unique();
      state = state.copyWith(
        isChallenging: true, challengingName: target.name, matchOpponent: target, activeChallengeId: rowId,
      );

      await tablesDB!.createRow(
        databaseId: dbId, tableId: challengesId, rowId: rowId,
        data: {
          'challengerId': _myUserId, 'challengerName': _myName, 'challengerLevel': _myLevel,
          'challengedId': target.id, 'status': 'pending', 'difficulty': 'hard',
          'p1Ready': false, 'p2Ready': false, 'p1Cleared': 0, 'p2Cleared': 0, 'winnerId': '',
        },
      );
    } catch (e) {
      debugPrint('🔴 [Challenge] Send error: $e');
      cancelChallenge();
    }
  }

  Future<Challenger?> acceptIncomingCall() async {
    final caller = state.incomingCaller;
    if (caller != null && caller.challengeDocId != null && tablesDB != null) {
      try {
        await tablesDB!.updateRow(
          databaseId: dbId, tableId: challengesId, rowId: caller.challengeDocId!,
          data: {'status': 'accepted'},
        );
        state = state.copyWith(
          clearIncomingCaller: true, isMatchAccepted: true,
          matchOpponent: caller, activeChallengeId: caller.challengeDocId,
        );
        return caller;
      } catch (e) {
        debugPrint('🔴 Accept error: $e');
      }
    }
    return null;
  }

  Future<void> cancelChallenge() async {
    final id = state.activeChallengeId;
    resetChallengeState();
    if (id != null && tablesDB != null) {
      try { await tablesDB!.deleteRow(databaseId: dbId, tableId: challengesId, rowId: id); } catch (_) {}
    }
  }

  Future<void> declineIncomingCall() async {
    final caller = state.incomingCaller;
    state = state.copyWith(clearIncomingCaller: true);
    if (caller != null && caller.challengeDocId != null && tablesDB != null) {
      try { await tablesDB!.deleteRow(databaseId: dbId, tableId: challengesId, rowId: caller.challengeDocId!); } catch (_) {}
    }
  }

  Future<void> toggleMatchReady(bool isP1) async {
    final id = state.activeChallengeId;
    if (id == null || tablesDB == null) return;
    final newP1 = isP1 ? !state.p1Ready : state.p1Ready;
    final newP2 = !isP1 ? !state.p2Ready : state.p2Ready;
    state = state.copyWith(p1Ready: newP1, p2Ready: newP2);
    try {
      await tablesDB!.updateRow(databaseId: dbId, tableId: challengesId, rowId: id, data: { 'p1Ready': newP1, 'p2Ready': newP2 });
    } catch (_) {}
  }

  Future<void> updateDifficulty(String diff, bool isP1) async {
    final id = state.activeChallengeId;
    if (id == null || tablesDB == null || !isP1) return;
    state = state.copyWith(difficulty: diff);
    try {
      await tablesDB!.updateRow(databaseId: dbId, tableId: challengesId, rowId: id, data: { 'difficulty': diff });
    } catch (_) {}
  }

  Future<void> startMatch(bool isP1) async {
    final id = state.activeChallengeId;
    if (id == null || tablesDB == null || !isP1) return;
    final seed = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    try {
      await tablesDB!.updateRow(databaseId: dbId, tableId: challengesId, rowId: id, data: { 'status': 'starting', 'matchSeed': seed });
    } catch (e) {
      debugPrint('🔴 Start match error: $e');
    }
  }

  Future<void> updateMatchProgress(int cleared, bool isP1) async {
    final id = state.activeChallengeId;
    if (id == null || tablesDB == null) return;
    try {
      await tablesDB!.updateRow(
        databaseId: dbId, tableId: challengesId, rowId: id,
        data: isP1 ? {'p1Cleared': cleared} : {'p2Cleared': cleared},
      );
    } catch (_) {}
  }

  Future<void> finishMatch(String winnerId, bool isP1) async {
    final id = state.activeChallengeId;
    if (id == null || tablesDB == null) return;
    try {
      await tablesDB!.updateRow(
        databaseId: dbId, tableId: challengesId, rowId: id,
        // 👈 MUST update both status and winnerId
        data: { 'status': 'finished', 'winnerId': winnerId },
      );
      debugPrint('✅ [Challenge] Match finished. Winner ID: $winnerId');
    } catch (e) {
      // 👈 If this fails, Appwrite is rejecting the update. Check the logs!
      debugPrint('🔴 [Challenge] Finish match error: $e');
    }
  }
}

final challengeProvider = NotifierProvider<ChallengeNotifier, ChallengeState>(ChallengeNotifier.new);