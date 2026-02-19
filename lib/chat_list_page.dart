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
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    // Load both standard chats and AI history from persistent storage
    Future.microtask(() {
      context.read<ChatProvider>().loadChats();
      context.read<ChatProvider>().loadAIHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chatProvider = context.watch<ChatProvider>();

    // UX FIX: Get all chats matching search query
    List<Chat> allResults = chatProvider.searchChats(_searchQuery);
    
    // UX FIX: Separate logic to stop duplication.
    // pinnedChats are only for the horizontal row. regularChats are for the vertical list.
    List<Chat> pinnedChats = allResults.where((c) => c.isPinned).toList();
    List<Chat> regularChats = allResults.where((c) => !c.isPinned).toList();

    // Apply category filters only to the regular list
    if (_selectedFilter == 'Unread') {
      regularChats = regularChats.where((c) => c.unreadCount > 0).toList();
    } else if (_selectedFilter == 'Groups') {
      regularChats = regularChats.where((c) => c.type == ChatType.group).toList();
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(colors, chatProvider),
              
              // 1. Horizontal Favorites (Pinned Users)
              if (!_isSearching && pinnedChats.isNotEmpty)
                SliverToBoxAdapter(child: _buildPinnedRow(colors, pinnedChats)),

              // 2. Filter Bar (All, Unread, Groups)
              SliverToBoxAdapter(child: _buildFilterBar(colors)),

              // 3. Main Chat List (Non-pinned users only)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: chatProvider.isLoading 
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildChatTile(context, colors, regularChats[index]),
                        childCount: regularChats.length,
                      ),
                    ),
              ),
            ],
          ),

          // THE AI FLOATING ACTION BUTTON (WhatsApp Style)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'ai_button_floating',
              onPressed: () => _navigateToAI(context),
              backgroundColor: Colors.white,
              elevation: 6,
              shape: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('images/logo.png'), // Your App Logo as the icon
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAI(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatDetailPage(
      chatId: 'ai_assistant',
      chatName: 'Here AI',
      chatAvatar: 'images/logo.png', 
      isGroup: false,
      isAI: true, 
    )));
  }

  Widget _buildAppBar(ColorScheme colors, ChatProvider provider) {
    return SliverAppBar(
      floating: true, pinned: true,
      centerTitle: false,
      title: _isSearching 
        ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
            onChanged: (v) => setState(() => _searchQuery = v),
          )
        : Text('Messages', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800)),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search), 
          onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) _searchQuery = '';
          })
        ),
      ],
    );
  }

  Widget _buildPinnedRow(ColorScheme colors, List<Chat> pinned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 12),
          child: Text("PINNED", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: pinned.length,
            itemBuilder: (context, i) => InkWell(
              onTap: () => _openChat(pinned[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CircleAvatar(radius: 30, backgroundImage: NetworkImage(pinned[i].avatar)),
                    const SizedBox(height: 6),
                    Text(pinned[i].name.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 20, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildFilterBar(ColorScheme colors) {
    final filters = ['All', 'Unread', 'Groups'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: filters.map((f) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f),
              selected: _selectedFilter == f,
              onSelected: (_) => setState(() => _selectedFilter = f),
              selectedColor: colors.primaryContainer,
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ColorScheme colors, Chat chat) {
    return ListTile(
      leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage(chat.avatar)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("9:28", style: TextStyle(fontSize: 11, color: colors.outline)),
        ],
      ),
      subtitle: Text(
        chat.lastMessage.content, 
        maxLines: 1, 
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
      trailing: chat.unreadCount > 0 
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
              child: Text('${chat.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : null,
      onTap: () => _openChat(chat),
    );
  }

  void _openChat(Chat chat) {
    context.read<ChatProvider>().markAsRead(chat.id); //
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(
      chatId: chat.id, 
      chatName: chat.name, 
      chatAvatar: chat.avatar, 
      isGroup: chat.type == ChatType.group,
    )));
  }
}
