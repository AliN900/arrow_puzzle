import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ──────────────────────────────────────────────────
class FriendModel {
  final String id;
  final String friendshipId;
  final String name;
  final int level;
  final bool isOnline;

  FriendModel({
    required this.id,
    required this.friendshipId,
    required this.name,
    required this.level,
    required this.isOnline,
  });
}

class FriendRequest {
  final String id;
  final String senderId;
  final String name;
  final int level;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.name,
    required this.level,
  });
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isMe;

  ChatMessage({required this.sender, required this.text, required this.isMe});
}

// ── State ───────────────────────────────────────────────────
class FriendsState {
  final List<FriendModel> friends;
  final List<FriendRequest> requests;
  final Map<String, List<ChatMessage>> chats;
  final List<FriendModel> searchResults;
  final bool isSearching;
  // 👈 Map of Target User ID -> Friend Request Document ID
  final Map<String, String> sentRequests;
  final Set<String> unreadFriendIds;

  FriendsState({
    required this.friends,
    required this.requests,
    required this.chats,
    this.searchResults = const [],
    this.isSearching = false,
    this.sentRequests = const {}, // Changed from List to Map
    this.unreadFriendIds = const {},
  });

  FriendsState copyWith({
    List<FriendModel>? friends,
    List<FriendRequest>? requests,
    Map<String, List<ChatMessage>>? chats,
    List<FriendModel>? searchResults,
    bool? isSearching,
    Map<String, String>? sentRequests,
    Set<String>? unreadFriendIds,
  }) {
    return FriendsState(
      friends: friends ?? this.friends,
      requests: requests ?? this.requests,
      chats: chats ?? this.chats,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      sentRequests: sentRequests ?? this.sentRequests,
      unreadFriendIds: unreadFriendIds ?? this.unreadFriendIds,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────
class FriendsNotifier extends Notifier<FriendsState> {
  final String dbId = '6ac33f510029701224d3';
  final String usersId = '6ae356e900356fdb7ddb';
  final String requestsId = '6ae3574a00017dce9e6f';
  final String friendshipsId = '6ae3578800188bbc653e';
  final String messagesId = '6ae36ded0017a1a70e8d';

  TablesDB? tablesDB;
  Realtime? realtime;

  String? _myUserId;
  String? _myName;
  int? _myLevel;

  RealtimeSubscription? _requestSub;
  RealtimeSubscription? _friendshipSub;
  RealtimeSubscription? _messageSub;

  @override
  FriendsState build() {
    ref.onDispose(() {
      _requestSub?.close();
      _friendshipSub?.close();
      _messageSub?.close();
    });
    return FriendsState(friends: [], requests: [], chats: {});
  }

  void initAppwrite(TablesDB db, Realtime rt, String userId, String userName, int level) {
    if (tablesDB != null && _myUserId == userId) return;

    tablesDB = db;
    realtime = rt;
    _myUserId = userId;
    _myName = userName;
    _myLevel = level;

    fetchFriends();
    fetchRequests();
    _listenForRealtimeUpdates();
  }

  void clearChatHistory(String friendId) {
    final newChats = Map<String, List<ChatMessage>>.from(state.chats);
    newChats.remove(friendId);
    state = state.copyWith(chats: newChats);
  }

  Future<void> fetchFriends() async {
    if (tablesDB == null || _myUserId == null) return;
    try {
      final res = await tablesDB!.listRows(
        databaseId: dbId,
        tableId: friendshipsId,
        queries: [
          Query.or([
            Query.equal('userA_id', _myUserId!),
            Query.equal('userB_id', _myUserId!),
          ])
        ],
      );

      final list = res.rows.map((row) {
        final isUserA = row.data['userA_id'] == _myUserId;
        return FriendModel(
          id: isUserA ? row.data['userB_id'] : row.data['userA_id'],
          friendshipId: row.$id,
          name: isUserA ? row.data['userB_name'] : row.data['userA_name'],
          level: isUserA ? row.data['userB_level'] : row.data['userA_level'],
          isOnline: isUserA ? row.data['userB_online'] ?? false : row.data['userA_online'] ?? false,
        );
      }).toList();

      final currentFriendIds = list.map((f) => f.id).toSet();
      final cleanedUnreadIds = state.unreadFriendIds.intersection(currentFriendIds);

      state = state.copyWith(
        friends: list,
        unreadFriendIds: cleanedUnreadIds,
      );
    } catch (e) {
      debugPrint('🔴 [Friends] Error fetching friends: $e');
    }
  }

  Future<void> fetchRequests() async {
    if (tablesDB == null || _myUserId == null) return;
    try {
      // 1. Incoming
      final incomingRes = await tablesDB!.listRows(
        databaseId: dbId,
        tableId: requestsId,
        queries: [
          Query.equal('receiverId', _myUserId!),
          Query.equal('status', 'pending'),
        ],
      );

      final incomingList = incomingRes.rows.map((row) {
        return FriendRequest(
          id: row.$id,
          senderId: row.data['senderId'],
          name: row.data['senderName'],
          level: row.data['senderLevel'],
        );
      }).toList();

      // 2. Outgoing (Map targetUserId -> RequestDocId)
      final outgoingRes = await tablesDB!.listRows(
        databaseId: dbId,
        tableId: requestsId,
        queries: [
          Query.equal('senderId', _myUserId!),
          Query.equal('status', 'pending'),
        ],
      );

      final outgoingMap = {
        for (var row in outgoingRes.rows)
          row.data['receiverId'] as String: row.$id
      };

      state = state.copyWith(
        requests: incomingList,
        sentRequests: outgoingMap,
      );
    } catch (e) {
      debugPrint('🔴 [Friends] Error fetching requests: $e');
    }
  }

  Future<void> searchUsers(String query) async {
    if (tablesDB == null || _myUserId == null) return;

    state = state.copyWith(isSearching: true);
    try {
      final res = await tablesDB!.listRows(
        databaseId: dbId,
        tableId: usersId,
        queries: [
          Query.search('userName', query),
        ],
      );

      final list = res.rows
          .where((row) => row.$id != _myUserId)
          .map((row) {
        return FriendModel(
          id: row.$id,
          friendshipId: '',
          name: row.data['userName'] ?? 'Unknown',
          level: row.data['level'] ?? 1,
          isOnline: row.data['isOnline'] ?? true,
        );
      }).toList();

      state = state.copyWith(searchResults: list, isSearching: false);
    } catch (e) {
      debugPrint('🔴 [Search] Appwrite Error: $e');
      state = state.copyWith(isSearching: false);
    }
  }

  Future<void> sendRequestToUser(String targetId, String targetName, int targetLevel) async {
    if (tablesDB == null || _myUserId == null) return;
    if (state.friends.any((f) => f.id == targetId)) return;
    if (state.sentRequests.containsKey(targetId)) return;

    try {
      final rowId = ID.unique();
      // Optimistically update UI
      state = state.copyWith(sentRequests: {...state.sentRequests, targetId: rowId});

      await tablesDB!.createRow(
        databaseId: dbId,
        tableId: requestsId,
        rowId: rowId,
        data: {
          'senderId': _myUserId,
          'senderName': _myName,
          'senderLevel': _myLevel,
          'receiverId': targetId,
          'status': 'pending',
        },
      );
    } catch (e) {
      debugPrint('🔴 [Friends] Error sending request: $e');
      // Revert
      final newMap = Map<String, String>.from(state.sentRequests)..remove(targetId);
      state = state.copyWith(sentRequests: newMap);
    }
  }

  // 👈 NEW: Cancel a sent request
  Future<void> cancelSentRequest(String targetId) async {
    if (tablesDB == null) return;
    final requestId = state.sentRequests[targetId];
    if (requestId == null) return;

    final newMap = Map<String, String>.from(state.sentRequests)..remove(targetId);
    state = state.copyWith(sentRequests: newMap);

    try {
      await tablesDB!.deleteRow(databaseId: dbId, tableId: requestsId, rowId: requestId);
    } catch (e) {
      debugPrint('🔴 [Friends] Error cancelling request: $e');
      fetchRequests(); // Revert on failure
    }
  }

  Future<void> acceptRequest(String requestId, String requesterId, String requesterName, int requesterLevel) async {
    if (tablesDB == null || _myUserId == null) return;

    state = state.copyWith(
      requests: state.requests.where((r) => r.id != requestId).toList(),
    );

    try {
      await tablesDB!.updateRow(
        databaseId: dbId,
        tableId: requestsId,
        rowId: requestId,
        data: {'status': 'accepted'},
      );

      await tablesDB!.createRow(
        databaseId: dbId,
        tableId: friendshipsId,
        rowId: ID.unique(),
        data: {
          'userA_id': _myUserId,
          'userA_name': _myName,
          'userA_level': _myLevel,
          'userA_online': true,
          'userB_id': requesterId,
          'userB_name': requesterName,
          'userB_level': requesterLevel,
          'userB_online': true,
        },
      );
      fetchFriends();
    } catch (e) {
      debugPrint('🔴 [Friends] Error accepting request: $e');
      fetchRequests();
    }
  }

  Future<void> rejectRequest(String requestId) async {
    if (tablesDB == null) return;

    state = state.copyWith(
      requests: state.requests.where((r) => r.id != requestId).toList(),
    );

    try {
      await tablesDB!.deleteRow(databaseId: dbId, tableId: requestsId, rowId: requestId);
    } catch (e) {
      debugPrint('🔴 [Friends] Error rejecting request: $e');
      fetchRequests();
    }
  }

  Future<void> removeFriend(String friendId, String friendshipDocId) async {
    if (tablesDB == null) return;

    state = state.copyWith(
      friends: state.friends.where((f) => f.id != friendId).toList(),
    );

    try {
      await tablesDB!.deleteRow(databaseId: dbId, tableId: friendshipsId, rowId: friendshipDocId);

      final reqRes = await tablesDB!.listRows(
          databaseId: dbId,
          tableId: requestsId,
          queries: [ Query.or([ Query.equal('senderId', _myUserId!), Query.equal('receiverId', _myUserId!) ]) ]
      );

      for (var row in reqRes.rows) {
        if (row.data['senderId'] == friendId || row.data['receiverId'] == friendId) {
          await tablesDB!.deleteRow(databaseId: dbId, tableId: requestsId, rowId: row.$id);
        }
      }
      fetchRequests();

    } catch (e) {
      debugPrint('🔴 [Friends] Error removing friend: $e');
      fetchFriends();
    }
  }

  void markChatAsRead(String friendId) {
    if (state.unreadFriendIds.contains(friendId)) {
      final newSet = Set<String>.from(state.unreadFriendIds)..remove(friendId);
      state = state.copyWith(unreadFriendIds: newSet);
    }
  }

  Future<void> sendMessage(String friendId, String text, String myName) async {
    if (tablesDB == null || _myUserId == null) return;

    final newMsg = ChatMessage(sender: myName, text: text, isMe: true);
    final currentChat = state.chats[friendId] ?? [];

    state = state.copyWith(
      chats: { ...state.chats, friendId: [...currentChat, newMsg] },
    );

    try {
      await tablesDB!.createRow(
        databaseId: dbId,
        tableId: messagesId,
        rowId: ID.unique(),
        data: {
          'senderId': _myUserId,
          'receiverId': friendId,
          'text': text,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('🔴 [Chat] Failed to send message: $e');
    }
  }

  void _listenForRealtimeUpdates() {
    // 1. Listen for incoming friend requests AND rejection/cancellation
    _requestSub = realtime!.subscribe(['databases.$dbId.tables.$requestsId.rows']);
    _requestSub!.stream.listen((response) {
      // If a new request arrives, OR a request is deleted/rejected
      if (response.events.contains('databases.*.tables.*.rows.*.create') ||
          response.events.contains('databases.*.tables.*.rows.*.delete')) {
        fetchRequests();
      }
    });

    // 2. Listen for friendships (Create AND Delete)
    _friendshipSub = realtime!.subscribe(['databases.$dbId.tables.$friendshipsId.rows']);
    _friendshipSub!.stream.listen((response) {
      if (response.events.contains('databases.*.tables.*.rows.*.create') ||
          response.events.contains('databases.*.tables.*.rows.*.delete')) {
        final data = response.payload;
        if (data['userA_id'] == _myUserId || data['userB_id'] == _myUserId) {
          fetchFriends();
          fetchRequests();
        }
      }
    });

    // 3. Listen for incoming Chat Messages
    _messageSub = realtime!.subscribe(['databases.$dbId.tables.$messagesId.rows']);
    _messageSub!.stream.listen((response) {
      if (response.events.contains('databases.*.tables.*.rows.*.create')) {
        final data = response.payload;
        if (data['receiverId'] == _myUserId) {
          final senderId = data['senderId'] as String;
          final text = data['text'] as String;
          final newMsg = ChatMessage(sender: 'Them', text: text, isMe: false);

          final newUnread = Set<String>.from(state.unreadFriendIds)..add(senderId);
          final currentChat = state.chats[senderId] ?? [];
          state = state.copyWith(
            chats: { ...state.chats, senderId: [...currentChat, newMsg] },
            unreadFriendIds: newUnread,
          );
        }
      }
    });
  }
}

final friendsProvider = NotifierProvider<FriendsNotifier, FriendsState>(FriendsNotifier.new);