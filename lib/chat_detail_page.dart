import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String chatAvatar;
  final bool isGroup;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.chatAvatar,
    required this.isGroup,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(
      chatId: widget.chatId,
      content: text,
    );
    
    _messageController.clear();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(context, colors),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: chatProvider.loadMessages(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Wrap in Dismissible for Swipe-to-Reply
                    return Dismissible(
                      key: Key(message.id),
                      direction: DismissDirection.startToEnd,
                      confirmDismiss: (_) async {
                        chatProvider.setReplyMessage(message);
                        return false; // Don't actually dismiss the tile
                      },
                      background: _buildReplyBackground(colors),
                      child: _buildMessageBubble(colors, message),
                    );
                  },
                );
              },
            ),
          ),
          
          // NEW: Reply Preview Bar (Shows above input field)
          if (chatProvider.replyingTo != null)
            _buildReplyPreview(colors, chatProvider),

          _buildInputArea(context, colors),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ColorScheme colors, ChatProvider provider) {
    final replyMsg = provider.replyingTo!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.5),
        border: Border(left: BorderSide(color: colors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  replyMsg.isMe ? "Replying to yourself" : "Replying to ${replyMsg.senderName}",
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  replyMsg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => provider.setReplyMessage(null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ColorScheme colors, Message message) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW: Quoted content inside the bubble
            if (message.replyToContent != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.black12 : colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(left: BorderSide(color: isMe ? Colors.white70 : colors.primary, width: 3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.replyToUser ?? "",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMe ? Colors.white : colors.primary),
                    ),
                    Text(
                      message.replyToContent!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: isMe ? Colors.white70 : colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            Text(
              message.content,
              style: TextStyle(color: isMe ? colors.onPrimary : colors.onSurface, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBackground(ColorScheme colors) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: Icon(Icons.reply, color: colors.primary),
    );
  }

  Widget _buildInputArea(BuildContext context, ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 16, right: 16, top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message...',
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _handleSendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colors) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(widget.chatAvatar)),
          const SizedBox(width: 12),
          Text(widget.chatName, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
