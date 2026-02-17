import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/providers/friends_provider.dart'; // You'll need to create this
import 'package:here/widgets/friend_request_card.dart';
import 'package:here/widgets/friend_tile.dart';
import 'package:here/widgets/suggestion_card.dart';
import 'package:here/profile.dart';

enum FriendsTab { all, online, requests, suggestions }

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  FriendsTab _selectedTab = FriendsTab.all;

  // Mock data - Replace with your actual provider
  final List<Map<String, dynamic>> _friendRequests = [
    {
      'id': '1',
      'name': 'Emma Watson',
      'username': '@emmawatson',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'mutualFriends': 12,
      'mutualFriendsList': ['John', 'Sarah', 'Mike', 'Anna', 'David', 'Lisa', 'Tom', 'Rachel', 'Chris', 'Emma', 'James', 'Sophie'],
      'mutualImages': [
        'https://randomuser.me/api/portraits/men/32.jpg',
        'https://randomuser.me/api/portraits/women/22.jpg',
        'https://randomuser.me/api/portraits/men/45.jpg',
      ],
      'timeAgo': '2 min ago',
    },
    {
      'id': '2',
      'name': 'Tom Holland',
      'username': '@tomholland',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'mutualFriends': 8,
      'mutualFriendsList': ['Zendaya', 'Jacob', 'Robert'],
      'mutualImages': [
        'https://randomuser.me/api/portraits/women/33.jpg',
        'https://randomuser.me/api/portraits/men/22.jpg',
      ],
      'timeAgo': '1 hour ago',
    },
  ];

  final List<Map<String, dynamic>> _friends = [
    {
      'id': '1',
      'name': 'John Doe',
      'username': '@johndoe',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
      'isOnline': true,
      'lastActive': 'Online',
      'mutualFriends': 15,
      'isCloseFriend': true,
      'isFavorite': true,
      'hasStory': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'username': '@janesmith',
      'image': 'https://randomuser.me/api/portraits/women/2.jpg',
      'isOnline': false,
      'lastActive': '2 hours ago',
      'mutualFriends': 8,
      'isCloseFriend': false,
      'isFavorite': false,
      'hasStory': false,
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'username': '@mikej',
      'image': 'https://randomuser.me/api/portraits/men/3.jpg',
      'isOnline': true,
      'lastActive': 'Online',
      'mutualFriends': 23,
      'isCloseFriend': true,
      'isFavorite': true,
      'hasStory': true,
    },
    {
      'id': '4',
      'name': 'Sarah Williams',
      'username': '@sarahw',
      'image': 'https://randomuser.me/api/portraits/women/4.jpg',
      'isOnline': false,
      'lastActive': '5 min ago',
      'mutualFriends': 5,
      'isCloseFriend': false,
      'isFavorite': false,
      'hasStory': true,
    },
    {
      'id': '5',
      'name': 'David Brown',
      'username': '@davidb',
      'image': 'https://randomuser.me/api/portraits/men/5.jpg',
      'isOnline': false,
      'lastActive': '1 day ago',
      'mutualFriends': 2,
      'isCloseFriend': false,
      'isFavorite': false,
      'hasStory': false,
    },
  ];

  final List<Map<String, dynamic>> _suggestions = [
    {
      'id': '1',
      'name': 'Alex Turner',
      'username': '@alexturner',
      'image': 'https://randomuser.me/api/portraits/men/6.jpg',
      'mutualFriends': 18,
      'mutualFriendsList': ['John', 'Jane', 'Mike'],
      'mutualImages': [
        'https://randomuser.me/api/portraits/men/1.jpg',
        'https://randomuser.me/api/portraits/women/2.jpg',
        'https://randomuser.me/api/portraits/men/3.jpg',
      ],
      'reason': 'Suggested for you',
      'isVerified': true,
    },
    {
      'id': '2',
      'name': 'Lisa Anderson',
      'username': '@lisaanderson',
      'image': 'https://randomuser.me/api/portraits/women/7.jpg',
      'mutualFriends': 6,
      'mutualFriendsList': ['Sarah', 'Mike'],
      'mutualImages': [
        'https://randomuser.me/api/portraits/women/4.jpg',
        'https://randomuser.me/api/portraits/men/3.jpg',
      ],
      'reason': 'Based on your interests',
      'isVerified': false,
    },
    {
      'id': '3',
      'name': 'Chris Evans',
      'username': '@chrisevans',
      'image': 'https://randomuser.me/api/portraits/men/8.jpg',
      'mutualFriends': 42,
      'mutualFriendsList': ['Robert', 'Scarlett', 'Mark', 'Jennifer'],
      'mutualImages': [
        'https://randomuser.me/api/portraits/men/9.jpg',
        'https://randomuser.me/api/portraits/women/10.jpg',
        'https://randomuser.me/api/portraits/men/11.jpg',
      ],
      'reason': 'Popular in your network',
      'isVerified': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedTab = FriendsTab.values[_tabController.index];
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredFriends() {
    if (_searchQuery.isEmpty) return _friends;
    return _friends.where((friend) {
      return friend['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             friend['username'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getOnlineFriends() {
    return _friends.where((friend) => friend['isOnline'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filteredFriends = _getFilteredFriends();
    final onlineFriends = _getOnlineFriends();

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Search
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
                      hintText: 'Search friends...',
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
                        'Friends',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Friend Request Badge
                      if (_friendRequests.isNotEmpty)
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.person_add_outlined, color: colors.onSurface),
                              onPressed: () {
                                _tabController.animateTo(2); // Go to requests tab
                              },
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  _friendRequests.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      IconButton(
                        icon: Icon(Icons.search, color: colors.onSurface),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
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

          // Tab Bar
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: colors.primary,
                indicatorWeight: 3,
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurface.withOpacity(0.6),
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline, size: 20),
                        const SizedBox(width: 8),
                        Text('All (${_friends.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Online (${onlineFriends.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.person_add_outlined, size: 20),
                        const SizedBox(width: 8),
                        if (_friendRequests.isNotEmpty)
                          Text('Requests (${_friendRequests.length})')
                        else
                          const Text('Requests'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      children: [
                        Icon(Icons.explore_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Suggestions'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pinned: true,
          ),

          // Tab Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: _buildTabContent(colors, filteredFriends, onlineFriends),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colors, List<Map<String, dynamic>> filteredFriends, List<Map<String, dynamic>> onlineFriends) {
    switch (_selectedTab) {
      case FriendsTab.all:
        return Column(
          children: [
            // Close Friends Section
            if (_friends.any((f) => f['isCloseFriend'] == true))
              _buildCloseFriendsSection(colors),
            
            // All Friends
            if (filteredFriends.isEmpty)
              _buildEmptyState(colors, 'No friends found')
            else
              ...filteredFriends.map((friend) => FriendTile(
                friend: friend,
                colors: colors,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: friend['id']), // Adjust as needed
                    ),
                  );
                },
                onMessage: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Messaging ${friend['name']}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: colors.primary,
                    ),
                  );
                },
              )),
          ],
        );

      case FriendsTab.online:
        if (onlineFriends.isEmpty) {
          return _buildEmptyState(colors, 'No friends online right now', icon: Icons.circle_outlined);
        }
        return Column(
          children: onlineFriends.map((friend) => FriendTile(
            friend: friend,
            colors: colors,
            showOnlineStatus: false,
            onTap: () {},
            onMessage: () {},
          )).toList(),
        );

      case FriendsTab.requests:
        return Column(
          children: [
            // Pending Requests
            if (_friendRequests.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(
                      'Pending Requests',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _friendRequests.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._friendRequests.map((request) => FriendRequestCard(
                request: request,
                colors: colors,
                onAccept: () {
                  setState(() {
                    // Remove from requests and add to friends
                    _friendRequests.remove(request);
                    // Add to _friends here
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request accepted!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onDecline: () {
                  setState(() {
                    _friendRequests.remove(request);
                  });
                },
                onViewProfile: () {
                  // Navigate to profile
                },
              )),
            ] else
              _buildEmptyState(colors, 'No pending requests', icon: Icons.person_add_disabled_outlined),
          ],
        );

      case FriendsTab.suggestions:
        return Column(
          children: [
            if (_suggestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text(
                      'People You May Know',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              ..._suggestions.map((suggestion) => SuggestionCard(
                suggestion: suggestion,
                colors: colors,
                onAddFriend: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Friend request sent to ${suggestion['name']}'),
                      backgroundColor: colors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onRemove: () {
                  setState(() {
                    _suggestions.remove(suggestion);
                  });
                },
              )),
            ] else
              _buildEmptyState(colors, 'No suggestions right now', icon: Icons.explore_outlined),
          ],
        );
    }
  }

  Widget _buildCloseFriendsSection(ColorScheme colors) {
    final closeFriends = _friends.where((f) => f['isCloseFriend'] == true).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.star, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Close Friends',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· ${closeFriends.length}',
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: closeFriends.length,
            itemBuilder: (context, index) {
              final friend = closeFriends[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(friend['image']),
                          backgroundColor: colors.surfaceContainerHighest,
                        ),
                        if (friend['isOnline'])
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        if (friend['hasStory'])
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend['name'].split(' ')[0],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colors, String message, {IconData? icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              icon ?? Icons.people_outline,
              size: 64,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for persistent tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}