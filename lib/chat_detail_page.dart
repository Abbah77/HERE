import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String chatAvatar;
  final bool isGroup;
  final bool isAI;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.chatAvatar,
    required this.isGroup,
    this.isAI = false,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (widget.isAI) {
      context.read<ChatProvider>().sendAIMessage(text);
    } else {
      context.read<ChatProvider>().sendMessage(
            chatId: widget.chatId,
            content: text,
          );
    }

    _messageController.clear();
    // Scroll to bottom after sending
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: _buildAppBar(context, colors),
      body: Column(
        children: [
          // 1. Message List Area
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: provider.loadMessages(widget.chatId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Latest messages at bottom
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index], colors);
                  },
                );
              },
            ),
          ),

          // 2. AI Thinking Indicator
          if (provider.isAILoading)
            _buildAIThinkingIndicator(colors),

          // 3. Reply Preview (if any)
          if (provider.replyingTo != null)
             _buildReplyPreview(provider, colors),

          // 4. Input Area
          _buildInputArea(context, colors),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, ColorScheme colors) {
    final bool isMe = message.isMe;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildAvatar(),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? colors.primary : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  // Logic: Use Markdown for AI assistant, standard text for user
                  child: (widget.isAI && !isMe)
                      ? MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.inter(color: colors.onSurfaceVariant),
                            code: GoogleFonts.firaCode(backgroundColor: Colors.black12),
                          ),
                        )
                      : Text(
                          message.content,
                          style: GoogleFonts.inter(
                            color: isMe ? colors.onPrimary : colors.onSurfaceVariant,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 44, right: 4),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(fontSize: 10, color: colors.outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundImage: widget.isAI 
        ? AssetImage(widget.chatAvatar) as ImageProvider
        : NetworkImage(widget.chatAvatar),
    );
  }

  Widget _buildAIThinkingIndicator(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
          ),
          const SizedBox(width: 8),
          Text("Here AI is thinking...", style: TextStyle(fontSize: 12, color: colors.primary)),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ChatProvider provider, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.replyingTo!.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
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

  Widget _buildInputArea(BuildContext context, ColorScheme colors) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 16,
        right: 16,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: widget.isAI ? "Ask Here AI anything..." : "Message...",
                filled: true,
                fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _handleSend,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colors) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chatName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                widget.isAI ? "AI Assistant" : "Online",
                style: TextStyle(fontSize: 11, color: colors.primary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}
