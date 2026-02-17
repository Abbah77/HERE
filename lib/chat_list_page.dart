import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/chat_detail_page.dart'; // We'll create this next

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Mock data - Replace with your ChatProvider data
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'Emma Watson',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'lastMessage': 'Hey! Are we still meeting tomorrow?',
      'lastMessageTime': '2 min ago',
      'unreadCount': 3,
      'isOnline': true,
      'isTyping': false,
      'isMuted': false,
      'isPinned': true,
      'type': 'individual',
    },
    {
      'id': '2',
      'name': 'Design Team',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'lastMessage': 'Mike: I\'ve updated the mockups',
      'lastMessageTime': '1 hour ago',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': true,
      'isMuted': false,
      'isPinned': true,
      'type': 'group',
      'members': 8,
    },
    {
      'id': '3',
      'name': 'Tom Holland',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'lastMessage': 'Thanks for the help! 🎬',
      'lastMessageTime': '3 hours ago',
      'unreadCount': 1,
      'isOnline': true,
      'isTyping': false,
      'isMuted': true,
      'isPinned': false,
      'type': 'individual',
    },
    {
      'id': '4',
      'name': 'Project Alpha',
      'avatar': 'https://randomuser.me/api/portraits/women/22.jpg',
      'lastMessage': 'Sarah: When\'s the deadline?',
      'lastMessageTime': 'Yesterday',
      'unreadCount': 5,
      'isOnline': false,
      'isTyping': false,
      'isMuted': false,
      'isPinned': false,
      'type': 'group',
      'members': 12,
    },
    {
      'id': '5',
      'name': 'Zendaya',
      'avatar': 'https://randomuser.me/api/portraits/women/33.jpg',
      'lastMessage': 'Can\'t wait for the weekend! ✨',
      'lastMessageTime': 'Yesterday',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': false,
      'isMuted': false,
      'isPinned': false,
      'type': 'individual',
    },
    {
      'id': '6',
      'name': 'Marketing Team',
      'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
      'lastMessage': 'John: New campaign ideas',
      'lastMessageTime': '2 days ago',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': false,
      'isMuted': false,
      'isPinned': false,
      'type': 'group',
      'members': 6,
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _pinnedChats {
    return _chats.where((chat) => chat['isPinned'] == true).toList();
  }

  List<Map<String, dynamic>> get _unreadChats {
    return _chats.where((chat) => chat['unreadCount'] > 0).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pinnedChats = _pinnedChats;
    final unreadChats = _unreadChats;
    final filteredChats = _filteredChats;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: colors.surface,
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: colors.onSurface.withOpacity(0.5)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: colors.onSurface),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                : Row(
                    children: [
                      Text(
                        'Messages',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Unread badge
                      if (unreadChats.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${unreadChats.length} new',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.search, color: colors.onSurface),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: colors.onSurface),
                        onPressed: () {
                          // TODO: New message/compose
                        },
                      ),
                    ],
                  ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Filters
          SliverToBoxAdapter(
            child: Container(
              color: colors.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      colors,
                      label: 'All',
                      icon: Icons.chat_bubble_outline,
                      isSelected: true,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      colors,
                      label: 'Unread',
                      count: unreadChats.length,
                      icon: Icons.mark_chat_unread_outlined,
                      isSelected: false,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      colors,
                      label: 'Groups',
                      icon: Icons.group_outlined,
                      isSelected: false,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      colors,
                      label: 'Online',
                      icon: Icons.circle,
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pinned Chats Section
          if (pinnedChats.isNotEmpty && !_isSearching && _searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: colors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.push_pin_outlined, color: colors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Pinned',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pinnedChats.length,
                        itemBuilder: (context, index) {
                          final chat = pinnedChats[index];
                          return _buildPinnedAvatar(colors, chat);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Chat List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (filteredChats.isEmpty) {
                    return _buildEmptyState(colors);
                  }
                  final chat = filteredChats[index];
                  return _buildChatTile(context, colors, chat);
                },
                childCount: filteredChats.isEmpty ? 1 : filteredChats.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: New chat
        },
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        child: const Icon(Icons.message_outlined),
      ),
    );
  }

  Widget _buildFilterChip(
    ColorScheme colors, {
    required String label,
    IconData? icon,
    int? count,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? colors.primary : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSelected ? colors.primary : colors.outline,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.onPrimary : colors.onSurface,
              ),
            if (icon != null) const SizedBox(width: 6),
            Text(
              count != null ? '$label $count' : label,
              style: TextStyle(
                color: isSelected ? colors.onPrimary : colors.onSurface,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedAvatar(ColorScheme colors, Map<String, dynamic> chat) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(chat['avatar']),
                backgroundColor: colors.surfaceContainerHighest,
              ),
              if (chat['isOnline'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                  ),
                ),
              if (chat['unreadCount'] > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      chat['unreadCount'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            chat['name'].split(' ').first,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ColorScheme colors, Map<String, dynamic> chat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: chat['id'],
              chatName: chat['name'],
              chatAvatar: chat['avatar'],
              isGroup: chat['type'] == 'group',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with status
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(chat['avatar']),
                  backgroundColor: colors.surfaceContainerHighest,
                ),
                if (chat['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                    ),
                  ),
                if (chat['type'] == 'group')
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.group,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: chat['unreadCount'] > 0 ? FontWeight.bold : FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (chat['isPinned'])
                        Icon(Icons.push_pin, color: colors.primary, size: 14),
                      if (chat['isMuted'])
                        Icon(Icons.volume_off_outlined, color: colors.onSurface.withOpacity(0.4), size: 14),
                      const SizedBox(width: 8),
                      Text(
                        chat['lastMessageTime'],
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat['isTyping'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Typing',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 20,
                                child: _TypingIndicator(color: colors.primary),
                              ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            chat['lastMessage'],
                            style: TextStyle(
                              color: chat['unreadCount'] > 0
                                  ? colors.onSurface
                                  : colors.onSurface.withOpacity(0.6),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (chat['unreadCount'] > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              chat['unreadCount'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No messages yet' : 'No matches found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Start a conversation with someone',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Start new chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('New Message'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom typing indicator animation
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
    return Row(
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
    );
  }
}