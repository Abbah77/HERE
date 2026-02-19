import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/chat_provider.dart';
import 'package:here/chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Logic: Fetch chats from server/mock on load
    Future.microtask(() => context.read<ChatProvider>().loadChats());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chatProvider = context.watch<ChatProvider>();
    
    // Logic: Filter data based on search and top chips
    List<Chat> displayChats = chatProvider.searchChats(_searchQuery);
    if (_activeFilter == 'Unread') displayChats = displayChats.where((c) => c.unreadCount > 0).toList();
    if (_activeFilter == 'Groups') displayChats = displayChats.where((c) => c.type == ChatType.group).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, colors, chatProvider),
          
          // 1. Filter Chips
          SliverToBoxAdapter(
            child: _buildFilterSection(colors, chatProvider),
          ),

          // 2. Pinned Horizontal List
          if (!_isSearching && chatProvider.pinnedChats.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildPinnedSection(colors, chatProvider.pinnedChats),
            ),

          // 3. Main Chat List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: chatProvider.isLoading 
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : displayChats.isEmpty 
                  ? SliverFillRemaining(child: _buildEmptyState(colors))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildChatTile(context, colors, displayChats[index]),
                        childCount: displayChats.length,
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: Implement contacts selection
        backgroundColor: colors.primary,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colors, ChatProvider provider) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: colors.surface,
      centerTitle: false,
      title: _isSearching 
        ? _buildSearchField(colors)
        : Text(
            'Messages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
      actions: [
        if (!_isSearching) ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _isSearching = true),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ]
      ],
    );
  }

  Widget _buildSearchField(ColorScheme colors) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(hintText: 'Search chats...', border: InputBorder.none),
      onChanged: (v) => setState(() => _searchQuery = v),
      suffixIcon: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => setState(() {
          _isSearching = false;
          _searchQuery = '';
          _searchController.clear();
        }),
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme colors, ChatProvider provider) {
    final filters = ['All', 'Unread', 'Groups'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _activeFilter = filter),
              backgroundColor: colors.surface,
              selectedColor: colors.primary.withOpacity(0.2),
              checkmarkColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? colors.primary : colors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPinnedSection(ColorScheme colors, List<Chat> pinned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("PINNED", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: colors.outline)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: pinned.length,
            itemBuilder: (context, index) => _buildPinnedAvatar(colors, pinned[index]),
          ),
        ),
        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildPinnedAvatar(ColorScheme colors, Chat chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 28, backgroundImage: NetworkImage(chat.avatar)),
              if (chat.participants.any((p) => p.isOnline))
                Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: colors.surface, width: 2)))),
            ],
          ),
          const SizedBox(height: 4),
          Text(chat.name.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ColorScheme colors, Chat chat) {
    return ListTile(
      onTap: () {
        context.read<ChatProvider>().markAsRead(chat.id);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(
          chatId: chat.id,
          chatName: chat.name,
          chatAvatar: chat.avatar,
          isGroup: chat.type == ChatType.group,
        )));
      },
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(chat.avatar)),
      title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: chat.isTyping 
        ? Text("typing...", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold))
        : Text(chat.lastMessage.content, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_formatTime(chat.lastMessageTime), style: TextStyle(fontSize: 12, color: colors.outline)),
          if (chat.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(10)),
              child: Text("${chat.unreadCount}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return "";
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(child: Text("No messages yet", style: TextStyle(color: colors.outline)));
  }
}
