import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/providers/auth_provider.dart';

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

class _ChatDetailPageState extends State<ChatDetailPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _typingController;
  bool _isSending = false;

  // Mock messages - Replace with your ChatProvider data
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'userId': 'other',
      'message': 'Hey! How are you?',
      'time': '10:30 AM',
      'status': 'read',
      'type': 'text',
    },
    {
      'id': '2',
      'userId': 'me',
      'message': 'I\'m good! Just working on the new features.',
      'time': '10:32 AM',
      'status': 'read',
      'type': 'text',
    },
    {
      'id': '3',
      'userId': 'other',
      'message': 'Sounds exciting! Can\'t wait to see them.',
      'time': '10:33 AM',
      'status': 'read',
      'type': 'text',
    },
    {
      'id': '4',
      'userId': 'me',
      'message': 'Check out this design!',
      'time': '10:35 AM',
      'status': 'read',
      'type': 'image',
      'imageUrl': 'https://via.placeholder.com/300',
    },
    {
      'id': '5',
      'userId': 'other',
      'message': 'Wow that looks amazing! 🔥',
      'time': '10:36 AM',
      'status': 'read',
      'type': 'text',
    },
    {
      'id': '6',
      'userId': 'other',
      'message': 'When is the release?',
      'time': '10:37 AM',
      'status': 'delivered',
      'type': 'text',
    },
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Simulate sending
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSending = false;
          _messageController.clear();
        });
        
        // Scroll to bottom
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, colors),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['userId'] == 'me';
                return _buildMessageBubble(colors, message, isMe);
              },
            ),
          ),

          // Typing indicator
          AnimatedBuilder(
            animation: _typingController,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: _typingController.isAnimating ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(widget.chatAvatar),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'typing',
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.5),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _TypingIndicator(color: colors.primary),
                ],
              ),
            ),
          ),

          // Message input
          _buildMessageInput(colors),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme colors) {
    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.chatAvatar),
                backgroundColor: colors.surfaceContainerHighest,
              ),
              // Online indicator (mock - you'd get this from provider)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  widget.isGroup ? '${widget.isGroup ? 8 : 1} participants' : 'Online',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.phone_outlined, color: colors.onSurface),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: colors.onSurface),
          onPressed: () {},
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: colors.onSurface),
          color: colors.surface,
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('View Profile', style: TextStyle(color: colors.onSurface)),
            ),
            PopupMenuItem(
              child: Text('Search', style: TextStyle(color: colors.onSurface)),
            ),
            PopupMenuItem(
              child: Text('Mute Notifications', style: TextStyle(color: colors.onSurface)),
            ),
            PopupMenuItem(
              child: Text('Clear Chat', style: TextStyle(color: colors.onSurface)),
            ),
            PopupMenuItem(
              child: Text('Block', style: TextStyle(color: colors.error)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ColorScheme colors, Map<String, dynamic> message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.chatAvatar),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message['type'] == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message['type'] == 'text')
                    Text(
                      message['message'],
                      style: TextStyle(
                        color: isMe ? colors.onPrimary : colors.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time'],
                        style: TextStyle(
                          color: isMe 
                              ? colors.onPrimary.withOpacity(0.7)
                              : colors.onSurface.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message['status'] == 'read' ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message['status'] == 'read'
                              ? Colors.blue
                              : colors.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            icon: Icon(Icons.attach_file_outlined, color: colors.onSurface),
            onPressed: () {
              // TODO: Show attachment options
            },
          ),
          
          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: colors.onSurface),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.emoji_emotions_outlined, 
                          color: colors.onSurface.withOpacity(0.7), size: 20),
                        onPressed: () {
                          // TODO: Open emoji picker
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined, 
                          color: colors.onSurface.withOpacity(0.7), size: 20),
                        onPressed: () {
                          // TODO: Open camera
                        },
                      ),
                    ],
                  ),
                ),
                onChanged: (text) {
                  // Simulate typing indicator
                  if (text.isNotEmpty && !_typingController.isAnimating) {
                    _typingController.forward();
                  } else if (text.isEmpty && _typingController.isAnimating) {
                    _typingController.reverse();
                  }
                },
              ),
            ),
          ),
          
          // Send button
          if (_messageController.text.isNotEmpty || _isSending)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : Icon(Icons.send, color: colors.onPrimary, size: 20),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
        ],
      ),
    );
  }
}

// Reuse the typing indicator from chat_list_page.dart
class _TypingIndicator extends StatefulWidget {
  final Color color;

  const _TypingIndicator({required this.color});

  @override
  State<_TypingIndicator> createState() => __TypingIndicatorState();
}

class __TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + index * 0.15,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 3,
                height: 3 * _animations[index].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}