import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle/l10n/app_localizations.dart';

import '../../../core/app_colors.dart';
import '../../../main.dart';
import '../../../widgets/status_flash.dart';
import '../providers/friends_provider.dart';

class FriendChatScreen extends ConsumerStatefulWidget {
  final FriendModel friend;
  const FriendChatScreen({super.key, required this.friend});

  @override
  ConsumerState<FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends ConsumerState<FriendChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsProvider.notifier).markChatAsRead(widget.friend.id);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _msgController.text.trim();
    if (text.isEmpty) return;

    final myName = ref.read(authServiceProvider).displayName;
    ref.read(friendsProvider.notifier).sendMessage(widget.friend.id, text, myName);

    if (presetText == null) {
      _msgController.clear();
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text('This will delete all messages in this chat for you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(friendsProvider.notifier).clearChatHistory(widget.friend.id);
              Navigator.pop(ctx);
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final bg = AppColors.background(context);
    final surface = AppColors.surface(context);
    final accent = AppColors.accent(context);
    final textPrimary = AppColors.textPrimary(context);

    // 👈 NEW: Watch for friend removal
    ref.listen(friendsProvider.select((s) => s.friends), (prev, next) {
      final wasFriend = prev?.any((f) => f.id == widget.friend.id) ?? false;
      final isFriend = next.any((f) => f.id == widget.friend.id);

      // If they were a friend, but now they are not, close the chat
      if (wasFriend && !isFriend) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context);
            StatusFlash.fail(context, '${widget.friend.name} removed you or is no longer your friend.');
          }
        });
      }
    });

    final messages = ref.watch(
        friendsProvider.select((state) => state.chats[widget.friend.id] ?? [])
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: accent.withValues(alpha: 0.2),
              child: Text(
                widget.friend.name.isNotEmpty
                    ? widget.friend.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: accent, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.friend.name,
                style: TextStyle(color: textPrimary, fontSize: 18)),
          ],
        ),
        iconTheme: IconThemeData(color: textPrimary),
        actions: [
          // 👈 ADDED DELETE CHAT BUTTON
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                strings.mpChatGreeting(widget.friend.name),
                style: TextStyle(
                    color: textPrimary.withValues(alpha: 0.5)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg.isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.isMe ? accent : surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: msg.isMe
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: msg.isMe
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      border: msg.isMe
                          ? null
                          : Border.all(
                          color: textPrimary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isMe ? Colors.white : textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 👈 QUICK REPLIES ROW
          Container(
            height: 44,
            padding: const EdgeInsets.only(left: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickReply(strings.chatQuickHello, accent, textPrimary),
                _buildQuickReply(strings.chatQuickChallenge, accent, textPrimary),
                _buildQuickReply(strings.chatQuickGoodGame, accent, textPrimary),
                _buildQuickReply(strings.chatQuickNice, accent, textPrimary),
                _buildQuickReply(strings.chatQuickWait, accent, textPrimary),
              ],
            ),
          ),

          SafeArea(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                    top: BorderSide(
                        color: textPrimary.withValues(alpha: 0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(color: textPrimary),
                      autofillHints: null,
                      keyboardType: TextInputType.text,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            color: textPrimary.withValues(alpha: 0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: bg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: accent,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReply(String text, Color accent, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: accent.withValues(alpha: 0.08),
        side: BorderSide(color: accent.withValues(alpha: 0.3), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}